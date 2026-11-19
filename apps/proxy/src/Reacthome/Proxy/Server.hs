module Reacthome.Proxy.Server where

import Control.Concurrent.Async (race)
import Control.Concurrent.Chan.Unagi (newChan, tryRead, tryReadChan, writeChan)
import Control.Monad (join)
import Data.ByteString (ByteString)
import Data.Function ((&))
import Data.String (IsString (fromString))
import Data.Text (Text, pack)
import Data.Text.Encoding (decodeUtf8', encodeUtf8)
import Data.UUID (UUID, fromText)
import Network.HTTP.Types (Query, decodePath)
import Reacthome.Proxy.Assets (Assets)
import Reacthome.Proxy.Bridge.Downstream (Downstream)
import Reacthome.Proxy.Config.App (ProxyConfig (..))
import Reacthome.Proxy.Error (ProxyError (..), logError)
import Reacthome.Proxy.Glue.Controller (Controller (..))
import Reacthome.Proxy.Glue.PubSub.Types (GluePublisher)
import Reacthome.Proxy.Sink (makeDirectSink)
import Reacthome.Proxy.Sink.DirectSinkRegistry (DirectSinkRegistry (add, delete))
import Reacthome.Proxy.Sink.SinkRegistry (SinkRegistry (directSinks))
import WebSockets.Connection (WebSocketConnection (..))
import WebSockets.Options (defaultWebSocketOptions)
import WebSockets.PendingConnection (WebSocketPendingConnection (..))
import WebSockets.Server (runWebSocketServer)

runProxyServer ::
    ( ?controller :: Controller
    , ?pubsub :: GluePublisher
    , ?assets :: Assets
    , ?sinks :: SinkRegistry
    , ?downstream :: Downstream
    ) =>
    ProxyConfig -> IO ()
runProxyServer config = do
    let ?options = defaultWebSocketOptions
    runWebSocketServer
        config.host
        config.port
        (proxyServer daemon)
  where
    daemon = fromString config.daemon

proxyServer ::
    ( ?controller :: Controller
    , ?pubsub :: GluePublisher
    , ?assets :: Assets
    , ?sinks :: SinkRegistry
    , ?downstream :: Downstream
    ) =>
    Text -> WebSocketPendingConnection -> IO ()
proxyServer daemon pending = do
    let (path, query) = decodePath pending.path
    if path == [daemon]
        then
            tryAccept query pending
        else
            logError $ InvalidProxyDaemon (show pending.path)

tryAccept ::
    ( ?controller :: Controller
    , ?pubsub :: GluePublisher
    , ?assets :: Assets
    , ?sinks :: SinkRegistry
    , ?downstream :: Downstream
    ) =>
    Query -> WebSocketPendingConnection -> IO ()
tryAccept query pending = do
    pending & case lookupQuery "peer" query of
        Just peer -> case fromText peer of
            Just uid -> justAccept uid
            _ -> rejectWith (InvalidPeer (show $ encodeUtf8 peer))
        _ -> rejectWith NoPeerPresent

justAccept ::
    ( ?controller :: Controller
    , ?pubsub :: GluePublisher
    , ?assets :: Assets
    , ?sinks :: SinkRegistry
    , ?downstream :: Downstream
    ) =>
    UUID -> WebSocketPendingConnection -> IO ()
justAccept uid pending = do
    pending.accept >>= \case
        Left !e -> logError $ WebSocketError e
        Right !connection -> do
            (inChan, outChan) <- newChan
            res <-
                either id id <$> race
                    do
                        let sink = makeDirectSink $ writeChan inChan
                        ?sinks.directSinks.add uid sink
                        connection.runReceiveMessageLoop $ ?controller.run uid sink
                    do
                        connection.runSendMessageLoop do
                            (!element, !wait) <- tryReadChan outChan
                            !message <- tryRead element
                            pure (message, wait)
            ?sinks.directSinks.delete uid
            logError $ WebSocketError res

rejectWith :: ProxyError -> WebSocketPendingConnection -> IO ()
rejectWith err pending = do
    logError err
    pending.reject $ encodeUtf8 . pack $ show err

lookupQuery :: ByteString -> Query -> Maybe Text
lookupQuery key query =
    case decodeUtf8' <$> join (lookup key query) of
        Just (Right value) -> Just value
        _ -> Nothing
