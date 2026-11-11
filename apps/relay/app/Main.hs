import Reacthome.Relay.App (application)
import Reacthome.Relay.Dispatcher
import Reacthome.Relay.Server
import WebSockets.Options (defaultWebSocketOptions)
import WebSockets.Server (runWebSocketServer)

main :: IO ()
main = do
  run "0.0.0.0" 3003
 where
  run host port = do
    let ?options = defaultWebSocketOptions
    dispatcher <- makeRelayDispatcher
    let ?server = makeRelayServer dispatcher
    putStrLn $ "Run Reacthome Relay on " <> host <> ":" <> show port
    runWebSocketServer host port application
