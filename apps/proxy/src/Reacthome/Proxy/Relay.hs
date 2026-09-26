module Reacthome.Proxy.Relay where

import Control.Monad (void)
import Data.ByteString.Lazy (empty)
import Reacthome.Proxy.Bridge.Downstream (Downstream (..))
import Reacthome.Proxy.Config (ClientConfig (..), ProxyConfig (..))
import Reacthome.Proxy.Daemon.Actions.Encode (actionGet)
import WebSockets.Client (runSecureWebSocketClient)
import WebSockets.Options (defaultWebSocketOptions)

runProxyRelay :: ClientConfig -> IO ()
runProxyRelay config = do
    let ?options = defaultWebSocketOptions
    let ?sink = print
    let ?source = pure (Nothing, pure empty)
    void $
        runSecureWebSocketClient
            config.host
            config.port
            config.uri

pingProxyDaemon ::
    (?downstream :: Downstream) =>
    ProxyConfig -> IO ()
pingProxyDaemon config =
    ?downstream.send $ actionGet config.daemon
