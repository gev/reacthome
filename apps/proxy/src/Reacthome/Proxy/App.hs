module Reacthome.Proxy.App where

import PubSub.Publisher (Publisher (..))
import Reacthome.Proxy.Config (Config (..))
import Reacthome.Proxy.Glue.Publisher (makeGluePublisher)
import Reacthome.Proxy.Glue.Store (GlueStore (..), makeGlueStore)
import Reacthome.Proxy.Server (logicServer)
import Reacthome.Proxy.Sink (makeSinkRegistry)
import WebSockets.Options (defaultWebSocketOptions)
import WebSockets.Server (runWebSocketServer)

app :: Config -> IO ()
app config = do
    sinks <- makeSinkRegistry
    let ?sinks = sinks

    let ?store = makeGlueStore config.path

    pubsub <- makeGluePublisher
    let ?pubsub = pubsub

    ?store.runWatcher pubsub.publish

    let ?options = defaultWebSocketOptions

    runWebSocketServer config.host config.port logicServer
