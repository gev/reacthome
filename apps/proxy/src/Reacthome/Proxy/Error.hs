module Reacthome.Proxy.Error where

import Control.Exception (Exception)
import Debug.Trace (traceIO)
import WebSockets.Error (WebSocketError)
import Prelude hiding (error)

data ProxyError
    = WebSocketError WebSocketError
    | InvalidProxyDaemon String
    | InvalidPeer String
    | NoPeerPresent
    | ConfigError String
    deriving (Show)

instance Exception ProxyError

logError :: ProxyError -> IO ()
logError err =
    traceIO $
        "[ERROR] " <> case err of
            WebSocketError e ->
                "WebSocket error, peer: " <> show e
            InvalidProxyDaemon d ->
                "Invalid daemon id to proxy: " <> d
            InvalidPeer p ->
                "Invalid peer id to proxy: " <> p
            NoPeerPresent -> "doesn't a peer present"
            ConfigError e ->
                "Invalid config: " <> e
