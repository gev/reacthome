module Reacthome.Proxy.App where

import Control.Concurrent (forkIO)
import Control.Monad (void, when)
import PubSub.Publisher (Publisher (..))
import Reacthome.Proxy.Assets (makeAssets)
import Reacthome.Proxy.Bridge.Downstream (makeDownstream)
import Reacthome.Proxy.Bridge.Upstream (makeUpstream)
import Reacthome.Proxy.Config.App (AppConfig (..))
import Reacthome.Proxy.Daemon (pingProxyDaemon, runProxyDaemon)
import Reacthome.Proxy.Discovery (Discovery (runAnnouncer, runResponder), makeProxyDiscovery)
import Reacthome.Proxy.Glue.Controller (makeController)
import Reacthome.Proxy.Glue.PubSub.Publisher (makeGluePublisher)
import Reacthome.Proxy.Glue.Store (GlueStore (..), makeGlueStore)
import Reacthome.Proxy.Relay (runProxyRelay)
import Reacthome.Proxy.Server (runProxyServer)
import Reacthome.Proxy.Sink.SinkRegistry (makeSinkRegistry)

runApp :: AppConfig -> IO ()
runApp config = do
  store <- makeGlueStore config.gluePath
  let ?store = store

  sinks <- makeSinkRegistry
  let ?sinks = sinks

  downstream <- makeDownstream
  let ?downstream = downstream

  pubsub <- makeGluePublisher
  let ?pubsub = pubsub

  discovery <- makeProxyDiscovery config.discovery config.proxy
  let ?discovery = discovery

  let ?upstream = makeUpstream config.proxy

  let ?assets = makeAssets config

  controller <- makeController
  let ?controller = controller

  -- print @String "Connect to relay..."
  -- fork do runProxyRelay config.relay config.proxy
  -- print @String "Connect to legacy daemon..."
  -- fork do runProxyDaemon config.daemon

  -- print @String "Ping to legacy daemon..."
  -- pingProxyDaemon config.proxy

  -- print @String "Run discovery announcer..."
  -- fork do discovery.runAnnouncer
  -- print @String "Run discovery responder..."
  -- fork do discovery.runResponder

  when config.watch do
    print @String "Run Glue modules watcher..."
    fork do ?store.runWatcher pubsub.publish

  print @String "Run proxy server..."
  runProxyServer config.proxy
 where
  fork = void . forkIO
