import Reacthome.Proxy.App (app)
import Reacthome.Proxy.Config (Config (..))

main :: IO ()
main = do
    putStrLn $
        "Run Reacthome Relay on "
            <> config.host
            <> ":"
            <> show
                config.port
    app config
  where
    config =
        Config
            { host = "127.0.0.1"
            , port = 3005
            , path = "./apps/proxy/glue/"
            }
