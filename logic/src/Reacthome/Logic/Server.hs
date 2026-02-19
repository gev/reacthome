module Reacthome.Logic.Server where

import Control.Concurrent.Async (race)
import Data.ByteString (toStrict)
import Data.UUID (UUID, toByteString)
import Reacthome.Logic.Error (LogicError (..), logError)
import WebSockets.Connection (WebSocketConnection (..))
import WebSockets.Options (WebSocketOptions)
import WebSockets.PendingConnection (WebSocketPendingConnection (..))
import Prelude hiding (lookup, take)

newtype LogicServer = LogicServer
    { accept :: WebSocketPendingConnection -> Peer -> IO ()
    }

type Peer = UUID

makeLogicServer ::
    (?options :: WebSocketOptions) =>
    LogicServer
makeLogicServer =
    let
        accept pending peer = do
            let
                dispatchMessage message = do
                    pure ()

                from = toStrict $ toByteString peer

            !successful <- pending.accept
            case successful of
                Left !e -> logError $ WebSocketError from e
                Right !connection -> do
                    res <-
                        either id id <$> race
                            do connection.runReceiveMessageLoop dispatchMessage
                            do connection.runSendMessageLoop undefined
                    logError $ WebSocketError from res
     in
        LogicServer{..}
