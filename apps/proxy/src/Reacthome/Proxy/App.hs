module Reacthome.Proxy.App where

import Control.Concurrent (forkIO)
import Control.Monad (void)
import PubSub.Publisher (Publisher (..))
import Reacthome.Proxy.Assets (makeAssets)
import Reacthome.Proxy.Bridge.Downstream (makeDownstream)
import Reacthome.Proxy.Bridge.Upstream (makeUpstream)
import Reacthome.Proxy.Config (AppConfig (..))
import Reacthome.Proxy.Daemon (runProxyDaemon)
import Reacthome.Proxy.Glue.PubSub.Publisher (makeGluePublisher)
import Reacthome.Proxy.Glue.Store (GlueStore (..), makeGlueStore)
import Reacthome.Proxy.Server (runProxyServer)
import Reacthome.Proxy.Sink (makeSinkRegistry)

runApp :: AppConfig -> IO ()
runApp config = do
    let ?store = makeGlueStore config.gluePath

    sinks <- makeSinkRegistry
    let ?sinks = sinks

    downstream <- makeDownstream
    let ?downstream = downstream

    pubsub <- makeGluePublisher
    let ?pubsub = pubsub

    upstream <- makeUpstream
    let ?upstream = upstream

    let ?assets = makeAssets config.assetsPath

    void . forkIO $ runProxyServer config.server
    void . forkIO $ runProxyDaemon config.daemon

    ?store.runWatcher pubsub.publish
