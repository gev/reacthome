module Reacthome.Proxy.Relay where

import Control.Monad (void)
import Data.ByteString.Lazy (empty)
import Reacthome.Proxy.Config.App (ClientConfig (..), ProxyConfig (..))
import WebSockets.Client (runSecureWebSocketClient)
import WebSockets.Options (defaultWebSocketOptions)

runProxyRelay :: ClientConfig -> ProxyConfig -> IO ()
runProxyRelay config proxy = do
    let uri = "/v1?peer=" <> proxy.daemon
    let ?options = defaultWebSocketOptions
    let ?sink = print
    let ?source = pure (Nothing, pure empty)
    void $
        runSecureWebSocketClient
            config.host
            config.port
            uri
