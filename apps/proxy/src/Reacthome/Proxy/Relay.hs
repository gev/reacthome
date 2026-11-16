module Reacthome.Proxy.Relay where

import Control.Concurrent.Chan.Unagi.Bounded (Element (tryRead), newChan, tryReadChan, writeChan)
import Control.Monad (guard, void)
import Data.ByteString (fromStrict, toStrict)
import Data.UUID (fromByteString, fromString, toByteString)
import Reacthome.Proxy.Assets (Assets)
import Reacthome.Proxy.Bridge.Downstream (Downstream)
import Reacthome.Proxy.Config.App (ClientConfig (..), ProxyConfig (..))
import Reacthome.Proxy.Error (ProxyError (InvalidPeer, InvalidProxyDaemon), logError)
import Reacthome.Proxy.Glue.Controller (controller)
import Reacthome.Proxy.Glue.PubSub.Types (GluePublisher)
import Reacthome.Proxy.Sink (SinkRegistry (..))
import Reacthome.Relay.Message (RelayMessage (..), RelayMessageHeader (..), getMessageHeader, getMessagePayload, isMessageValid, serializeMessage)
import WebSockets.Client (runWebSocketClient)
import WebSockets.Options (defaultWebSocketOptions)

runProxyRelay ::
    ( ?pubsub :: GluePublisher
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
            (inChan, outChan) <- newChan 10_000
            let ?options = defaultWebSocketOptions
            let ?sink =
                    \message -> do
                        guard $ isMessageValid message
                        let header = getMessageHeader message
                        case fromByteString (fromStrict header.from) of
                            Just uid -> do
                                let ?session = uid
                                sink <-
                                    ?sinks.lookup uid >>= \case
                                        Just sink -> pure sink
                                        Nothing -> do
                                            let sink = writeChan inChan
                                            ?sinks.add uid \content -> do
                                                let to = header.from
                                                let header = RelayMessageHeader{..}
                                                let message = RelayMessage{..}
                                                sink $ serializeMessage message
                                            pure sink
                                let ?sink = sink
                                controller $ getMessagePayload message
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
