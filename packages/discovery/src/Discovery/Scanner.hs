module Discovery.Scanner where

import Control.Monad
import Discovery.Config
import Discovery.Monitor
import Discovery.Prober
import Discovery.Utils

scan :: (?announce :: AnnounceConfig) => IO ()
scan = forever do
    monitor
        ?announce.group
        ?announce.port
        ?announce.onMessage
    delay ?announce.timeout

probe'n'scan :: (?announce :: AnnounceConfig, ?probe :: ProbeConfig) => IO ()
probe'n'scan = forever do
    probe
    monitor
        ?announce.group
        ?announce.port
        ?announce.onMessage
    delay ?announce.timeout
