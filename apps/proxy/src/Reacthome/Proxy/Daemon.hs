module Reacthome.Proxy.Daemon where

import Control.Monad (void)
import Reacthome.Proxy.Bridge (Bridge (..), Downstream (..), Upstream (..))
import Reacthome.Proxy.Config (DaemonConfig (..))
import WebSockets.Client (runWebSocketClient)
import WebSockets.Options (defaultWebSocketOptions)

runProxyDaemon :: (?bridge :: Bridge) => DaemonConfig -> IO ()
runProxyDaemon config = do
    let ?options = defaultWebSocketOptions
    let ?sink = ?bridge.upstream.publish
    let ?source = ?bridge.downstream.receive
    void $
        runWebSocketClient
            config.host
            config.port
            config.uri
