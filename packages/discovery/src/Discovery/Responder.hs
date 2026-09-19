module Discovery.Responder where

import Control.Monad
import Discovery.Config
import Discovery.Monitor
import Discovery.Utils
import Network.Socket.ByteString

respond :: (?announce :: AnnounceConfig, ?probe :: ProbeConfig) => IO ()
respond = forever do
    monitor ?probe.group ?probe.port \sock msg from -> do
        when (msg == ?probe.message) do
            let to = setPort from ?announce.port
            sendAllTo sock ?announce.message to
    delay ?probe.timeout
