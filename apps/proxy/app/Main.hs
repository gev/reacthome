import Reacthome.Proxy.App (runApp)
import Reacthome.Proxy.Config (AppConfig (..), AssetsConfig (..), DaemonConfig (..), DiscoveryConfig (..), ProxyConfig (..))

main :: IO ()
main = do
    let config =
            AppConfig
                { proxy =
                    ProxyConfig
                        { host = "0.0.0.0"
                        , port = 3005
                        , daemon = "a265dc7e-62c4-451e-9299-305fb97742b9"
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
                        , announceGroup = "239.0.20.26"
                        , announcePort = 2026
                        , probeGroup = "239.0.20.27"
                        , probePort = 2027
                        , interval = 10
                        , timeout = 1
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
            <> config.proxy.host
            <> ":"
            <> show config.proxy.port
    runApp config
