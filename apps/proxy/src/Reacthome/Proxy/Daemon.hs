module Reacthome.Proxy.Daemon where

import Control.Monad (void)
import Reacthome.Proxy.Config (DaemonConfig (..))
import WebSockets.Client (runWebSocketClient)
import WebSockets.Options (defaultWebSocketOptions)

runProxyDaemon :: DaemonConfig -> IO ()
runProxyDaemon config = do
    ()
    let ?options = defaultWebSocketOptions
    let ?sink = undefined
    let ?source = undefined
    void $
        runWebSocketClient
            config.host
            config.port
            config.uri
