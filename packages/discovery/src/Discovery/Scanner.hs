module Discovery.Scanner where

import Control.Monad
import Discovery.Config
import Discovery.Monitor
import Discovery.Prober
import Discovery.Utils

scan :: (?annonce :: AnnonceConfig) => IO ()
scan = forever do
    monitor
        ?annonce.group
        ?annonce.port
        ?annonce.onMessage
    delay ?annonce.timeout

probe'n'scan :: (?annonce :: AnnonceConfig, ?probe :: ProbeConfig) => IO ()
probe'n'scan = forever do
    probe
    monitor
        ?annonce.group
        ?annonce.port
        ?annonce.onMessage
    delay ?annonce.timeout
