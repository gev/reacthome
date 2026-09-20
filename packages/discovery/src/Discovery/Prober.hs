module Discovery.Prober where

import Data.ByteString
import Discovery.Broadcaster
import Discovery.Config
import Discovery.Utils

probe :: (?probe :: ProbeConfig) => ByteString -> IO ()
probe message = do
    addr <- resolve ?probe.group ?probe.port
    broadcast addr message
