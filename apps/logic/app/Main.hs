import Reacthome.Logic.Server (accept, makeLogicServer)
import WebSockets.Options (defaultWebSocketOptions)
import WebSockets.Server (runWebSocketServer)

main :: IO ()
main =
  run "127.0.0.1" 3005
  where
    run host port = do
      let ?options = defaultWebSocketOptions
      let server = makeLogicServer
      putStrLn $ "Run Reacthome Relay on " <> host <> ":" <> show port
      runWebSocketServer host port server.accept
