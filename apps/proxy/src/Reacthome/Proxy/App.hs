module Reacthome.Proxy.App where

import Control.Concurrent (forkIO)
import Control.Monad (void)
import PubSub.Publisher (Publisher (..))
import Reacthome.Proxy.Assets (makeAssets)
import Reacthome.Proxy.Bridge.Cache (makeCache)
import Reacthome.Proxy.Bridge.Downstream (makeDownstream)
import Reacthome.Proxy.Bridge.Upstream (makeUpstream)
import Reacthome.Proxy.Config (AppConfig (..))
import Reacthome.Proxy.Daemon (pingProxyDaemon, runProxyDaemon)
import Reacthome.Proxy.Discovery
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

    cache <- makeCache
    let ?cache = cache

    pubsub <- makeGluePublisher
    let ?pubsub = pubsub

    discovery <- makeProxyDiscovery config.discovery config.proxy
    let ?discovery = discovery

    let ?upstream = makeUpstream config.proxy

    let ?assets = makeAssets config.assets

    void . forkIO $ runProxyServer config.proxy
    void . forkIO $ runProxyDaemon config.daemon
    void . forkIO $ discovery.runAnnouncer

    pingProxyDaemon config.proxy

    ?store.runWatcher pubsub.publish
