module Discovery.Announcer where

import Control.Monad
import Discovery.Broadcaster
import Discovery.Config
import Discovery.Utils

announce :: (?announce :: AnnounceConfig) => IO ()
announce = do
    addr <- resolve ?announce.group ?announce.port
    forever do
        broadcast addr ?announce.message
        delay ?announce.interval
