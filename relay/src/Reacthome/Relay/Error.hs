module Reacthome.Relay.Error
    ( RelayError (..)
    , logError
    ) where

import Control.Exception (Exception)
import Debug.Trace (traceIO)
import Reacthome.Relay (StrictRaw, Uid)
import Util.Encoding.Error (EncodingError)
import WebSockets.Error (WebSocketError)
import Prelude hiding (error)

data RelayError
    = InvalidPeer EncodingError
    | InvalidDestination StrictRaw
    | NoPeersFound Uid
    | WebSocketError Uid WebSocketError
    | InvalidMessageLength
        { messageLength :: Int
        , minimumLength :: Int
        }
    deriving (Show, Exception)

logError :: RelayError -> IO ()
logError err =
    traceIO $
        "[ERROR] " <> case err of
            InvalidMessageLength{..} ->
                "Invalid message length: got "
                    <> show messageLength
                    <> ", expected at least "
                    <> show minimumLength
            InvalidPeer e ->
                "Invalid UUID in message: " <> show e
            InvalidDestination uid ->
                "Invalid UUID in message: " <> show uid
            NoPeersFound peer ->
                "No relays found for UUID: " <> show peer
            WebSocketError peer e ->
                "WebSocket error, peer " <> show peer <> ": " <> show e
