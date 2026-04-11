import Reacthome.Relay.App (application)
import WebSockets.Options (defaultWebSocketOptions)
import WebSockets.Server (runWebSocketServer)

main :: IO ()
main =
    run "0.0.0.0" 3003
  where
    run host port = do
        let ?options = defaultWebSocketOptions
        putStrLn $ "Run Reacthome Relay on " <> host <> ":" <> show port
        runWebSocketServer host port application
