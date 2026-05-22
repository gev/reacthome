import Reacthome.Logic.Glue.Publisher (makeGluePublisher)
import Reacthome.Logic.Glue.Sink (makeSinkRegistry)
import Reacthome.Logic.Glue.Store (GlueStore (..), makeGlueStore)
import Reacthome.Logic.PubSub.Publisher (Publisher (..))
import Reacthome.Logic.Server (logicServer)
import WebSockets.Options (defaultWebSocketOptions)
import WebSockets.Server (runWebSocketServer)

main :: IO ()
main = do
    let path = "./apps/logic/glue/"
        host = "127.0.0.1"
        port = 3005

    sinks <- makeSinkRegistry
    let ?sinks = sinks

    let ?store = makeGlueStore path

    pubsub <- makeGluePublisher
    let ?pubsub = pubsub

    ?store.runWatcher pubsub.publish

    let ?options = defaultWebSocketOptions

    putStrLn $ "Run Reacthome Relay on " <> host <> ":" <> show port

    runWebSocketServer host port logicServer
