module Reacthome.Logic.Error where

import Control.Exception (Exception)
import Debug.Trace (traceIO)
import WebSockets.Error (WebSocketError)
import Prelude hiding (error)

newtype LogicError
    = WebSocketError WebSocketError
    deriving (Show)

instance Exception LogicError

logError :: LogicError -> IO ()
logError err =
    traceIO $
        "[ERROR] " <> case err of
            WebSocketError e ->
                "WebSocket error, peer " <> ": " <> show e
