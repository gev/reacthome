module Reacthome.Proxy.App where

import Control.Concurrent (forkIO)
import Control.Monad (void)
import PubSub.Publisher (Publisher (..))
import Reacthome.Proxy.Assets (makeAssets)
import Reacthome.Proxy.Config (AppConfig (..))
import Reacthome.Proxy.Glue.Publisher (makeGluePublisher)
import Reacthome.Proxy.Glue.Store (GlueStore (..), makeGlueStore)
import Reacthome.Proxy.Server (proxyServer)
import Reacthome.Proxy.Sink (makeSinkRegistry)
import WebSockets.Options (defaultWebSocketOptions)
import WebSockets.Server (runWebSocketServer)

app :: AppConfig -> IO ()
app config = do
    sinks <- makeSinkRegistry
    let ?sinks = sinks
    let ?store = makeGlueStore config.gluePath
    pubsub <- makeGluePublisher
    let ?pubsub = pubsub
    let ?assets = makeAssets config.assetsPath
    let ?options = defaultWebSocketOptions

    void . forkIO $
        runWebSocketServer
            config.listenHost
            config.listenPort
            proxyServer

    ?store.runWatcher pubsub.publish
