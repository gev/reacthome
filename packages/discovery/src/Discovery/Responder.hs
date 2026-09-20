module Discovery.Responder where

import Control.Monad
import Data.ByteString (ByteString)
import Discovery.Config
import Discovery.Monitor
import Discovery.Utils
import Network.Socket.ByteString

respond ::
    (?announce :: AnnounceConfig, ?probe :: ProbeConfig) =>
    (ByteString -> Maybe ByteString) -> IO ()
respond handle = forever do
    monitor ?probe.group ?probe.port \sock msg from -> do
        case handle msg of
            Just message -> do
                let to = setPort from ?announce.port
                sendAllTo sock message to
            Nothing -> pure ()
    delay ?probe.timeout
