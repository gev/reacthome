module Reacthome.Proxy.Error where

import Control.Exception (Exception)
import Debug.Trace (traceIO)
import WebSockets.Error (WebSocketError)
import Prelude hiding (error)

newtype ProxyError
    = WebSocketError WebSocketError
    deriving (Show)

instance Exception ProxyError

logError :: ProxyError -> IO ()
logError err =
    traceIO $
        "[ERROR] " <> case err of
            WebSocketError e ->
                "WebSocket error, peer " <> ": " <> show e
