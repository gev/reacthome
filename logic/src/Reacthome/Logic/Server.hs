module Reacthome.Logic.Server where

import Control.Concurrent.Async (race)
import Control.Concurrent.Chan.Unagi.Bounded (newChan, tryRead, tryReadChan, writeChan)
import Data.ByteString qualified as BS
import Reacthome.Logic.Error (LogicError (..), logError)
import WebSockets.Connection (WebSocketConnection (..))
import WebSockets.Options (WebSocketOptions)
import WebSockets.PendingConnection (WebSocketPendingConnection (..))
import Prelude hiding (lookup, take)

newtype LogicServer = LogicServer
    { accept :: WebSocketPendingConnection -> IO ()
    }

makeLogicServer ::
    (?options :: WebSocketOptions) =>
    IO LogicServer
makeLogicServer = do
    let
        accept pending = do
            !successful <- pending.accept
            case successful of
                Left !e -> logError $ WebSocketError e
                Right !connection -> do
                    (inChan, outChan) <- newChan 10
                    let
                        sink message = do
                            main <- BS.readFile "./logic/glue/main.glue"
                            writeChan inChan $ "(put store.cache \"main\" " <> main <> ")"
                            next <- BS.readFile "./logic/glue/next.glue"
                            writeChan inChan $ "(put store.cache \"next\" " <> next <> ")"
                        source = do
                            (!element, !wait) <- tryReadChan outChan
                            !message <- tryRead element
                            pure (message, wait)
                    res <-
                        either id id <$> race
                            do connection.runReceiveMessageLoop sink
                            do connection.runSendMessageLoop source
                    logError $ WebSocketError res
    pure
        LogicServer{..}
