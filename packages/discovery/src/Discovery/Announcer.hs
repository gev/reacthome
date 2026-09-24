module Discovery.Announcer where

import Control.Monad
import Data.ByteString (ByteString)
import Discovery.Broadcaster
import Discovery.Config
import Discovery.Utils

announce ::
    (?announce :: AnnounceConfig) =>
    IO (Maybe ByteString) -> IO ()
announce getMessage = do
    addr <- resolve ?announce.group ?announce.port
    forever do
        getMessage >>= maybe
            do pure ()
            do broadcast addr
        delay ?announce.interval
