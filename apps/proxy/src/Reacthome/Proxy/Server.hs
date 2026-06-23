module Reacthome.Proxy.Server where

import Control.Concurrent.Async (race)
import Control.Concurrent.Chan.Unagi.Bounded (newChan, tryRead, tryReadChan, writeChan)
import Data.UUID.V4 (nextRandom)
import Reacthome.Proxy.Assets (Assets)
import Reacthome.Proxy.Config (ServerConfig (..))
import Reacthome.Proxy.Error (ProxyError (..), logError)
import Reacthome.Proxy.Glue.Controller (controller)
import Reacthome.Proxy.Glue.Publisher (GluePublisher)
import Reacthome.Proxy.Sink (SinkRegistry (..))
import WebSockets.Connection (WebSocketConnection (..))
import WebSockets.Options (WebSocketOptions (..), defaultWebSocketOptions)
import WebSockets.PendingConnection (WebSocketPendingConnection (..))
import WebSockets.Server (runWebSocketServer)
import Prelude hiding (lookup, take)

runProxyServer ::
    ( ?pubsub :: GluePublisher
    , ?assets :: Assets
    , ?sinks :: SinkRegistry
    ) =>
    ServerConfig -> IO ()
runProxyServer config = do
    let ?options = defaultWebSocketOptions{bound = 10}
    runWebSocketServer
        config.host
        config.port
        proxyServer

proxyServer ::
    ( ?pubsub :: GluePublisher
    , ?assets :: Assets
    , ?sinks :: SinkRegistry
    , ?options :: WebSocketOptions
    ) =>
    WebSocketPendingConnection -> IO ()
proxyServer pending =
    pending.accept >>= \case
        Left !e -> logError $ WebSocketError e
        Right !connection -> do
            (inChan, outChan) <- newChan ?options.bound
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
            logError $ WebSocketError res
