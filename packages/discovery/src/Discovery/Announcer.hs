module Discovery.Announcer where

import Control.Monad
import Data.ByteString (ByteString)
import Discovery.Broadcaster
import Discovery.Config
import Discovery.Utils

announce ::
    (?announce :: AnnounceConfig) =>
    ByteString -> IO ()
announce message = do
    addr <- resolve ?announce.group ?announce.port
    forever do
        broadcast addr message
        delay ?announce.interval
