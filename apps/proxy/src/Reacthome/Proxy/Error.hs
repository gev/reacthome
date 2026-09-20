module Reacthome.Proxy.Error where

import Control.Exception (Exception)
import Data.ByteString (ByteString)
import Debug.Trace (traceIO)
import WebSockets.Error (WebSocketError)
import Prelude hiding (error)

data ProxyError
    = WebSocketError WebSocketError
    | InvalidProxyDaemon ByteString
    deriving (Show)

instance Exception ProxyError

logError :: ProxyError -> IO ()
logError err =
    traceIO $
        "[ERROR] " <> case err of
            WebSocketError e ->
                "WebSocket error, peer: " <> show e
            InvalidProxyDaemon d ->
                "Invalid daemon id to proxy: " <> show d
