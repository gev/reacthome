module Reacthome.Relay.Error where

import Control.Exception (Exception)
import Data.ByteString (ByteString)
import Data.Text (Text)
import Debug.Trace (traceIO)
import Reacthome.Relay (Uid)
import WebSockets.Error (WebSocketError)
import Prelude hiding (error)

data RelayError
    = InvalidUri ByteString
    | InvalidVersion Text
    | NoPeerPresent
    | InvalidPeer Text
    | InvalidDestination Uid
    | NoPeersFound Uid
    | WebSocketError Uid WebSocketError
    | InvalidMessageLength
        { messageLength :: Int
        , minimumLength :: Int
        }
    deriving (Show)

instance Exception RelayError

logError :: RelayError -> IO ()
logError err =
    traceIO $
        "[ERROR] " <> case err of
            InvalidUri uri ->
                "Invalid URI: " <> show uri
            InvalidVersion version ->
                "Invalid version: " <> show version
            NoPeerPresent ->
                "No peer present"
            InvalidPeer peer ->
                "Invalid peer UUID: " <> show peer
            InvalidDestination uid ->
                "Invalid destination UUID: " <> show uid
            NoPeersFound peer ->
                "No peers found for UUID: " <> show peer
            WebSocketError peer e ->
                "WebSocket error, peer " <> show peer <> ": " <> show e
            InvalidMessageLength{..} ->
                "Invalid message length: got "
                    <> show messageLength
                    <> ", expected at least "
                    <> show minimumLength
