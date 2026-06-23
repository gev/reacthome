module Reacthome.Proxy.Error where

import Control.Exception (Exception)
import Debug.Trace (traceIO)
import WebSockets.Error (WebSocketError)
import Prelude hiding (error)

newtype ProxyError
    = ProxyError WebSocketError
    deriving (Show)

instance Exception ProxyError

logError :: ProxyError -> IO ()
logError err =
    traceIO $
        "[ERROR] " <> case err of
            ProxyError e ->
                "WebSocket error, peer " <> ": " <> show e
