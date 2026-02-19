import Reacthome.Logic.App (application)
import Reacthome.Logic.Server (makeLogicServer)
import WebSockets.Options (defaultWebSocketOptions)
import WebSockets.Server (runWebSocketServer)

main :: IO ()
main =
    run "0.0.0.0" 3005
  where
    run host port = do
        let ?options = defaultWebSocketOptions
        let server = makeLogicServer
        putStrLn $ "Run Reacthome Relay on " <> host <> ":" <> show port
        runWebSocketServer host port $ application server
