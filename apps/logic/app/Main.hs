import Reacthome.Logic.Glue.Publisher (makeGluePublisher)
import Reacthome.Logic.Glue.Sink (makeSinkRegistry)
import Reacthome.Logic.Glue.Store (makeGlueStore)
import Reacthome.Logic.Server (logicServer)
import WebSockets.Options (defaultWebSocketOptions)
import WebSockets.Server (runWebSocketServer)

main :: IO ()
main = do
    let host = "127.0.0.1"
        port = 3005
    sinks <- makeSinkRegistry
    let ?sinks = sinks
    let ?store = makeGlueStore "./apps/logic/glue/"
    pubsub <- makeGluePublisher
    let ?options = defaultWebSocketOptions
    putStrLn $ "Run Reacthome Relay on " <> host <> ":" <> show port
    runWebSocketServer host port do
        let ?pubsub = pubsub
        logicServer
