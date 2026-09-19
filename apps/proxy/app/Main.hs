import Reacthome.Proxy.App (runApp)
import Reacthome.Proxy.Config (AppConfig (..), AssetsConfig (..), DaemonConfig (..), DiscoveryConfig (..), ServerConfig (..))

main :: IO ()
main = do
    let config =
            AppConfig
                { server =
                    ServerConfig
                        { host = "0.0.0.0"
                        , port = 3005
                        }
                , daemon =
                    DaemonConfig
                        { host = "server.local"
                        , port = 3000
                        , uri = "/"
                        }
                , discovery =
                    DiscoveryConfig
                        { announceInterval = 10
                        , announceGroup = "239.0.0.2026"
                        , announcePort = 2026
                        , probeGroup = "239.0.0.2027"
                        , probePort = 2027
                        }
                , gluePath = "./apps/proxy/glue/"
                , assets =
                    AssetsConfig
                        { path = "./assets"
                        , proxy = "/Users/evgenygazdovsky/workspace/reacthome-daemon-legacy/var/assets"
                        }
                }
    putStrLn $
        "Run Reacthome Proxy on "
            <> config.server.host
            <> ":"
            <> show config.server.port
    runApp config
