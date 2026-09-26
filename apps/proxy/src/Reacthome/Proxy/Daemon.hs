module Reacthome.Proxy.Daemon where

import Control.Concurrent (forkIO)
import Control.Monad (void)
import Reacthome.Proxy.Bridge.Downstream (Downstream (..))
import Reacthome.Proxy.Bridge.Upstream (Upstream (..))
import Reacthome.Proxy.Config (ClientConfig (..), ProxyConfig (..))
import Reacthome.Proxy.Daemon.Actions.Encode (actionGet)
import WebSockets.Client (runWebSocketClient)
import WebSockets.Options (defaultWebSocketOptions)

runProxyDaemon ::
    ( ?downstream :: Downstream
    , ?upstream :: Upstream
    ) =>
    ClientConfig -> IO ()
runProxyDaemon config = void $ forkIO do
    let ?options = defaultWebSocketOptions
    let ?sink = ?upstream.publish
    let ?source = ?downstream.receive
    void $
        runWebSocketClient
            config.host
            config.port
            config.uri

pingProxyDaemon ::
    (?downstream :: Downstream) =>
    ProxyConfig -> IO ()
pingProxyDaemon config =
    ?downstream.send $ actionGet config.daemon
