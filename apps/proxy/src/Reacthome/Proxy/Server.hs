module Reacthome.Proxy.Server where

import Control.Concurrent.Async (race)
import Control.Concurrent.Chan.Unagi.Bounded (newChan, tryRead, tryReadChan, writeChan)
import Data.ByteString.Lazy qualified as L
import Data.UUID.V4 (nextRandom)
import Reacthome.Proxy.Assets (Assets)
import Reacthome.Proxy.Error (ProxyError (..), logError)
import Reacthome.Proxy.Glue.Controller (controller)
import Reacthome.Proxy.Glue.Publisher (GluePublisher)
import Reacthome.Proxy.Sink (SinkRegistry (..))
import WebSockets.Connection (WebSocketConnection (..))
import WebSockets.Options (WebSocketOptions)
import WebSockets.PendingConnection (WebSocketPendingConnection (..))
import Prelude hiding (lookup, take)

logicServer ::
    ( ?options :: WebSocketOptions
    , ?pubsub :: GluePublisher
    , ?assets :: Assets
    , ?sinks :: SinkRegistry
    ) =>
    WebSocketPendingConnection -> IO ()
logicServer pending =
    pending.accept >>= \case
        Left !e -> logError $ WebSocketError e
        Right !connection -> do
            (inChan, outChan) <- newChan @L.ByteString 10
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
