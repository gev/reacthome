import Control.Concurrent (forkIO)
import Control.Monad
import Discovery.Annoncer
import Discovery.Config
import Discovery.Responder (respond)
import Discovery.Scanner

main :: IO ()
main = do
    let ?annonce =
            AnnonceConfig
                { group = "239.0.0.1"
                , port = 2026
                , message = "Hello"
                , interval = 10
                , timeout = 1
                , onMessage = \_ msg addr -> putStrLn $ show addr <> ": " <> show msg
                }
    let ?probe =
            ProbeConfig
                { group = "239.0.0.2"
                , port = 2027
                , message = "Probe"
                , timeout = 1
                }
    void $ forkIO respond
    void $ forkIO annonce
    probe'n'scan
