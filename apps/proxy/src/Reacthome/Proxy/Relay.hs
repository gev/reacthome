module Reacthome.Proxy.Relay where

import Control.Concurrent (threadDelay)
import Control.Monad (guard, void)
import Data.IORef (modifyIORef, newIORef)
import Data.Set (empty, insert)
import Reacthome.Proxy.Config.App (ClientConfig (..), ProxyConfig (..))
import Reacthome.Relay.Message (RelayMessageHeader (..), getMessageHeader, isMessageValid)
import WebSockets.Client (runWebSocketClient)
import WebSockets.Options (defaultWebSocketOptions)

runProxyRelay :: ClientConfig -> ProxyConfig -> IO ()
runProxyRelay config proxy = do
    peers <- newIORef empty
    let uri = "/v1?peer=" <> proxy.daemon
    print uri
    let ?options = defaultWebSocketOptions
    let ?sink =
            \message -> do
                guard $ isMessageValid message
                let header = getMessageHeader message
                modifyIORef peers (insert header.from)
                print message
    let ?source = pure (Nothing, threadDelay 100_000_000_000 >> pure "")
    void $
        runWebSocketClient
            config.secure
            config.host
            config.port
            uri
