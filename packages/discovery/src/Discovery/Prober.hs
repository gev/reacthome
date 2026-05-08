module Discovery.Prober where

import Discovery.Broadcaster
import Discovery.Config
import Discovery.Utils

probe :: (?probe :: ProbeConfig) => IO ()
probe = do
    addr <- resolve ?probe.group ?probe.port
    broadcast addr ?probe.message
