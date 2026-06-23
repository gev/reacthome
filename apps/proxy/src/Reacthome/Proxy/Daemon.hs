module Reacthome.Proxy.Daemon where

import Control.Concurrent.Chan.Unagi.Bounded (Element (tryRead), newChan, tryReadChan)
import Control.Monad (void)
import Reacthome.Proxy.Config (DaemonConfig (..))
import WebSockets.Client (runWebSocketClient)
import WebSockets.Options (defaultWebSocketOptions)

runProxyDaemon :: DaemonConfig -> IO ()
runProxyDaemon config = do
    let ?options = defaultWebSocketOptions
    (inChan, outChan) <- newChan 10
    let ?sink = print
    let ?source =
            do
                (!element, !wait) <- tryReadChan outChan
                !message <- tryRead element
                pure (message, wait)
    void $
        runWebSocketClient
            config.host
            config.port
            config.uri
