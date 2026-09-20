module Discovery.Scanner where

import Control.Monad
import Data.ByteString
import Discovery.Config
import Discovery.Monitor
import Discovery.Prober
import Discovery.Utils

scan ::
    (?announce :: AnnounceConfig) =>
    OnMessage -> IO ()
scan onMessage = forever do
    monitor
        ?announce.group
        ?announce.port
        onMessage
    delay ?announce.timeout

probe'n'scan ::
    (?announce :: AnnounceConfig, ?probe :: ProbeConfig) =>
    ByteString -> OnMessage -> IO ()
probe'n'scan message onMessage = forever do
    probe message
    monitor
        ?announce.group
        ?announce.port
        onMessage
    delay ?announce.timeout
