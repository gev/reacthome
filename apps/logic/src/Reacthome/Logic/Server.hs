module Reacthome.Logic.Server where

import Control.Concurrent.Async (race)
import Control.Concurrent.Chan.Unagi.Bounded (newChan, tryRead, tryReadChan, writeChan)
import Data.ByteString.Lazy qualified as L
import Reacthome.Logic.Error (LogicError (..), logError)
import Reacthome.Logic.Glue.Controller (controller)
import Reacthome.Logic.Glue.Publisher (GluePublisher)
import WebSockets.Connection (WebSocketConnection (..))
import WebSockets.Options (WebSocketOptions)
import WebSockets.PendingConnection (WebSocketPendingConnection (..))
import Prelude hiding (lookup, take)

newtype LogicServer = LogicServer
    { accept :: WebSocketPendingConnection -> IO ()
    }

makeLogicServer ::
    ( ?options :: WebSocketOptions
    , ?pubsub :: GluePublisher
    ) =>
    LogicServer
makeLogicServer = do
    let
        accept pending =
            pending.accept >>= \case
                Left !e -> logError $ WebSocketError e
                Right !connection -> do
                    (inChan, outChan) <- newChan @L.ByteString 10
                    res <-
                        either id id <$> race
                            do
                                let ?sink = writeChan inChan
                                connection.runReceiveMessageLoop controller
                            do
                                connection.runSendMessageLoop do
                                    (!element, !wait) <- tryReadChan outChan
                                    !message <- tryRead element
                                    pure (message, wait)
                    logError $ WebSocketError res
    LogicServer{..}
