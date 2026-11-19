module Reacthome.Proxy.Relay where

import Control.Concurrent.Chan.Unagi (Element (tryRead), newChan, tryReadChan, writeChan)
import Control.Monad (guard, void)
import Data.ByteString (fromStrict, toStrict)
import Data.UUID (fromByteString, fromString, toByteString)
import Reacthome.Proxy.Assets (Assets)
import Reacthome.Proxy.Bridge.Downstream (Downstream)
import Reacthome.Proxy.Config.App (ClientConfig (..), ProxyConfig (..))
import Reacthome.Proxy.Error (ProxyError (InvalidPeer, InvalidProxyDaemon), logError)
import Reacthome.Proxy.Glue.Controller (Controller (..))
import Reacthome.Proxy.Glue.PubSub.Types (GluePublisher)
import Reacthome.Proxy.Sink (makeRelaySink)
import Reacthome.Proxy.Sink.RelaySinkRegistry (RelaySinkRegistry (..))
import Reacthome.Proxy.Sink.SinkRegistry (SinkRegistry (..))
import Reacthome.Relay.Message (RelayMessageHeader (..), getMessageHeader, getMessagePayload, isMessageValid)
import WebSockets.Client (runWebSocketClient)
import WebSockets.Options (defaultWebSocketOptions)

runProxyRelay ::
    ( ?controller :: Controller
    , ?pubsub :: GluePublisher
    , ?assets :: Assets
    , ?sinks :: SinkRegistry
    , ?downstream :: Downstream
    ) =>
    ClientConfig -> ProxyConfig -> IO ()
runProxyRelay config proxy =
    case toStrict . toByteString <$> fromString proxy.daemon of
        Nothing -> logError $ InvalidProxyDaemon (show proxy.daemon)
        Just from -> do
            let uri = "/v1?peer=" <> proxy.daemon
            (inChan, outChan) <- newChan
            let ?options = defaultWebSocketOptions
            let ?sink =
                    \message -> do
                        guard $ isMessageValid message
                        let header = getMessageHeader message
                        case fromByteString (fromStrict header.from) of
                            Just uid -> do
                                sink <-
                                    ?sinks.relaySinks.lookup uid >>= \case
                                        Just s -> do
                                            ?sinks.relaySinks.actualize uid
                                            pure s
                                        Nothing -> do
                                            let s = makeRelaySink from header.from $ writeChan inChan
                                            ?sinks.relaySinks.add uid s
                                            pure s
                                ?sinks.relaySinks.add uid sink
                                ?controller.run uid sink $ getMessagePayload message
                            Nothing -> logError $ InvalidPeer (show header.from)
            let ?source =
                    do
                        (!element, !wait) <- tryReadChan outChan
                        !message <- tryRead element
                        pure (message, wait)
            void $
                runWebSocketClient
                    config.secure
                    config.host
                    config.port
                    uri
