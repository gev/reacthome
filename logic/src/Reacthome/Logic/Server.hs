module Reacthome.Logic.Server where

import Control.Concurrent.Async (race)
import Control.Concurrent.Chan.Unagi.Bounded (newChan, tryRead, tryReadChan, writeChan)
import Data.ByteString (toStrict)
import Data.Text (Text)
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
    IO LogicServer
makeLogicServer = do
    (inChan, outChan) <- newChan 10
    let
        accept pending peer = do
            let
                sink message = do
                    print message
                    writeChan inChan message
                source = do
                    (!element, !wait) <- tryReadChan outChan
                    !message <- tryRead element
                    pure (message, wait)

                from = toStrict $ toByteString peer

            !successful <- pending.accept
            case successful of
                Left !e -> logError $ WebSocketError from e
                Right !connection -> do
                    res <-
                        either id id <$> race
                            do connection.runReceiveMessageLoop sink
                            do connection.runSendMessageLoop source
                    logError $ WebSocketError from res
    pure
        LogicServer{..}
