import Reacthome.Logic.App (application)
import Reacthome.Logic.Server (makeLogicServer)
import WebSockets.Options (defaultWebSocketOptions)
import WebSockets.Server (runWebSocketServer)

main :: IO ()
main =
  run "127.0.0.1" 3005
 where
  run host port = do
    let ?options = defaultWebSocketOptions
    server <- makeLogicServer
    putStrLn $ "Run Reacthome Relay on " <> host <> ":" <> show port
    runWebSocketServer host port $ application server
