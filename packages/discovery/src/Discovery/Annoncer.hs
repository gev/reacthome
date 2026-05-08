module Discovery.Annoncer where

import Control.Monad
import Discovery.Broadcaster
import Discovery.Config
import Discovery.Utils

annonce :: (?annonce :: AnnonceConfig) => IO ()
annonce = do
    addr <- resolve ?annonce.group ?annonce.port
    forever do
        broadcast addr ?annonce.message
        delay ?annonce.interval
