import Reacthome.Proxy.App (runApp)
import Reacthome.Proxy.Config (AppConfig (..), DaemonConfig (..), ServerConfig (..))

main :: IO ()
main = do
    let config =
            AppConfig
                { server =
                    ServerConfig
                        { host = "127.0.0.1"
                        , port = 3005
                        }
                , daemon =
                    DaemonConfig
                        { uid = "02aaee3f-a050-43d5-bbf2-e0f2abd73a6e"
                        , host = "127.0.0.1"
                        , port = 3000
                        , uri = "/"
                        }
                , gluePath = "./apps/proxy/glue/"
                , assetsPath = "./assets"
                }
    putStrLn $
        "Run Reacthome Relay on "
            <> config.server.host
            <> ":"
            <> show config.server.port
    runApp config
