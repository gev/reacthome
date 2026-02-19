module Reacthome.Logic.Error where

import Control.Exception (Exception)
import Data.Text (Text)
import Debug.Trace (traceIO)
import Reacthome.Logic (Uid)
import WebSockets.Error (WebSocketError)
import Prelude hiding (error)

data LogicError
    = InvalidUUID Text
    | WebSocketError Uid WebSocketError
    | InvalidMessageLength
        { messageLength :: Int
        , minimumLength :: Int
        }
    deriving (Show)

instance Exception LogicError

logError :: LogicError -> IO ()
logError err =
    traceIO $
        "[ERROR] " <> case err of
            InvalidMessageLength{..} ->
                "Invalid message length: got "
                    <> show messageLength
                    <> ", expected at least "
                    <> show minimumLength
            InvalidUUID bytes ->
                "Invalid UUID in message: " <> show bytes
            WebSocketError peer e ->
                "WebSocket error, peer " <> show peer <> ": " <> show e
