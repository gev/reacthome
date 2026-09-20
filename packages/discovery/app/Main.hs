import Control.Concurrent (forkIO)
import Control.Monad
import Discovery.Announcer
import Discovery.Config
import Discovery.Responder (respond)
import Discovery.Scanner

main :: IO ()
main = do
    let ?announce =
            AnnounceConfig
                { group = "239.0.0.1"
                , port = 2026
                , interval = 10
                , timeout = 1
                }

    let ?probe =
            ProbeConfig
                { group = "239.0.0.2"
                , port = 2027
                , timeout = 1
                }

    let announceMessage = "Hello"
    let probeMessage = "Probe"

    void $
        forkIO
            ( respond \msg ->
                if msg == probeMessage
                    then Just announceMessage
                    else Nothing
            )

    void $
        forkIO
            (announce announceMessage)

    probe'n'scan
        probeMessage
        \_ msg addr ->
            putStrLn $ show addr <> ": " <> show msg
