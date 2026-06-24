module Reacthome.Proxy.Daemon where

import Control.Monad (void)
import Reacthome.Proxy.Bridge (Downstream (..), Upstream (..))
import Reacthome.Proxy.Config (DaemonConfig (..))
import WebSockets.Client (runWebSocketClient)
import WebSockets.Options (defaultWebSocketOptions)

runProxyDaemon ::
    ( ?downstream :: Downstream
    , ?upstream :: Upstream
    ) =>
    DaemonConfig -> IO ()
runProxyDaemon config = do
    let ?options = defaultWebSocketOptions
    let ?sink = ?upstream.publish
    let ?source = ?downstream.receive
    void $
        runWebSocketClient
            config.host
            config.port
            config.uri
