import Reacthome.Proxy.App (app)
import Reacthome.Proxy.Config (AppConfig (..), DaemonConfig (..))

main :: IO ()
main = do
    putStrLn $
        "Run Reacthome Relay on "
            <> appConfig.listenHost
            <> ":"
            <> show appConfig.listenPort
    app appConfig
  where
    appConfig =
        AppConfig
            { listenHost = "127.0.0.1"
            , listenPort = 3005
            , gluePath = "./apps/proxy/glue/"
            , assetsPath = "./assets"
            }
    daemonConfig =
        DaemonConfig
            { daemon = "02aaee3f-a050-43d5-bbf2-e0f2abd73a6e"
            , daemonHost = "127.0.0.1"
            , daemonPort = 3000
            }
