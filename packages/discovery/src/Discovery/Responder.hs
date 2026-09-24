module Discovery.Responder where

import Control.Monad (forever)
import Data.ByteString (ByteString)
import Discovery.Config (AnnounceConfig (..), ProbeConfig (..))
import Discovery.Monitor (monitor)
import Discovery.Utils (delay, setPort)
import Network.Socket.ByteString (sendAllTo)

respond ::
    (?announce :: AnnounceConfig, ?probe :: ProbeConfig) =>
    (ByteString -> IO (Maybe ByteString)) -> IO ()
respond handle = forever do
    monitor ?probe.group ?probe.port \sock msg from ->
        handle msg
            >>= maybe
                do pure ()
                do send sock from

    delay ?probe.timeout
  where
    send sock from message = do
        let to = setPort from ?announce.port
        sendAllTo sock message to
