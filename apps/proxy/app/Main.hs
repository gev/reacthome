import Reacthome.Proxy.App (runApp)
import Reacthome.Proxy.Config.App (AppConfig (..), ProxyConfig (..))
import Reacthome.Proxy.Config.Load (loadConfig)

main :: IO ()
main =
    loadConfig >>= \case
        Left err -> print err
        Right config -> do
            putStrLn $
                "Run Reacthome Proxy on "
                    <> config.proxy.host
                    <> ":"
                    <> show config.proxy.port
            runApp config
