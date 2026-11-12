module Reacthome.Proxy.Relay where

import Control.Concurrent (threadDelay)
import Control.Monad (guard, unless, void, when)
import Data.ByteString.Lazy (empty)
import Reacthome.Proxy.Config.App (ClientConfig (..), ProxyConfig (..))
import Reacthome.Relay.Message (isMessageValid)
import WebSockets.Client (runSecureWebSocketClient, runWebSocketClient)
import WebSockets.Options (defaultWebSocketOptions)

runProxyRelay :: ClientConfig -> ProxyConfig -> IO ()
runProxyRelay config proxy = do
    let uri = "/v1?peer=" <> proxy.daemon
    print uri
    let ?options = defaultWebSocketOptions
    let ?sink =
            \message -> do
                guard $ isMessageValid message
                print message
    let ?source = pure (Nothing, threadDelay 100_000_000_000 >> pure empty)
    void $
        -- runSecureWebSocketClient
        --     config.host
        --     config.port
        --     uri
        runWebSocketClient
            "127.0.0.1"
            3003
            uri
