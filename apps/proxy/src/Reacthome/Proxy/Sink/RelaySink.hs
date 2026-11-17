module Reacthome.Proxy.Sink.RelaySink where

import Data.Functor ((<&>))
import Data.Time.Clock.POSIX (getPOSIXTime)
import Reacthome.Relay (LazyRaw, Uid)
import Reacthome.Relay.Message (RelayMessage (..), RelayMessageHeader (..), serializeMessage)

data RelaySink = RelaySink
    { send :: LazyRaw -> IO ()
    , timestamp :: Int
    }

makeRelaySink :: Uid -> Uid -> (LazyRaw -> IO ()) -> IO RelaySink
makeRelaySink from to send =
    now <&> RelaySink \content -> do
        let header = RelayMessageHeader{..}
        let message = RelayMessage{..}
        send $ serializeMessage message

now :: IO Int
now = round <$> getPOSIXTime
