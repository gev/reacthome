import Reacthome.Proxy.App (runApp)
import Reacthome.Proxy.Config.Load (loadConfig)

main :: IO ()
main =
    loadConfig >>= \case
        Left err -> print err
        Right config -> runApp config
