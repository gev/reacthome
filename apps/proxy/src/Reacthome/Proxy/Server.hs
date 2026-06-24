module Reacthome.Proxy.Server where

import Control.Concurrent.Async (race)
import Control.Concurrent.Chan.Unagi.Bounded (newChan, tryRead, tryReadChan, writeChan)
import Data.UUID.V4 (nextRandom)
import Reacthome.Proxy.Assets (Assets)
import Reacthome.Proxy.Bridge (Downstream)
import Reacthome.Proxy.Config (ServerConfig (..))
import Reacthome.Proxy.Error (ProxyError (..), logError)
import Reacthome.Proxy.Glue.Controller (controller)
import Reacthome.Proxy.Glue.PubSub.GlueOp (GluePublisher)
import Reacthome.Proxy.Sink (SinkRegistry (..))
import WebSockets.Connection (WebSocketConnection (..))
import WebSockets.Options (defaultWebSocketOptions)
import WebSockets.PendingConnection (WebSocketPendingConnection (..))
import WebSockets.Server (runWebSocketServer)
import Prelude hiding (lookup, take)

runProxyServer ::
    ( ?pubsub :: GluePublisher
    , ?assets :: Assets
    , ?sinks :: SinkRegistry
    , ?downstream :: Downstream
    ) =>
    ServerConfig -> IO ()
runProxyServer config = do
    let ?options = defaultWebSocketOptions
    runWebSocketServer
        config.host
        config.port
        proxyServer

proxyServer ::
    ( ?pubsub :: GluePublisher
    , ?assets :: Assets
    , ?sinks :: SinkRegistry
    , ?downstream :: Downstream
    ) =>
    WebSocketPendingConnection -> IO ()
proxyServer pending =
    pending.accept >>= \case
        Left !e -> logError $ ProxyError e
        Right !connection -> do
            (inChan, outChan) <- newChan 10
            res <-
                either id id <$> race
                    do
                        uid <- nextRandom
                        let ?sink = writeChan inChan
                        let ?session = uid
                        ?sinks.add uid ?sink
                        connection.runReceiveMessageLoop controller
                    do
                        connection.runSendMessageLoop do
                            (!element, !wait) <- tryReadChan outChan
                            !message <- tryRead element
                            pure (message, wait)
            logError $ ProxyError res
