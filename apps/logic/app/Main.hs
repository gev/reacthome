import Reacthome.Logic.Glue.Publisher (makeGluePublisher)
import Reacthome.Logic.Glue.Sink (makeSinkRegistry)
import Reacthome.Logic.Server (accept, makeLogicServer)
import WebSockets.Options (defaultWebSocketOptions)
import WebSockets.Server (runWebSocketServer)

main :: IO ()
main = do
    let host = "127.0.0.1"
        port = 3005
    pubsub <- makeGluePublisher
    sinks <- makeSinkRegistry
    let ?options = defaultWebSocketOptions
    putStrLn $ "Run Reacthome Relay on " <> host <> ":" <> show port
    runWebSocketServer host port do
        let ?pubsub = pubsub
        let ?sinks = sinks
        makeLogicServer.accept
