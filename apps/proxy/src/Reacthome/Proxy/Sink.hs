module Reacthome.Proxy.Sink where

import Reacthome.Relay (LazyRaw, Uid)
import Reacthome.Relay.Message (RelayMessage (..), RelayMessageHeader (..), serializeMessage)

newtype Sink = Sink
    { send :: LazyRaw -> IO ()
    }

makeDirectSink :: (LazyRaw -> IO ()) -> Sink
makeDirectSink = Sink

makeRelaySink :: Uid -> Uid -> (LazyRaw -> IO ()) -> Sink
makeRelaySink from to send =
    Sink \content -> do
        let header = RelayMessageHeader{..}
        let message = RelayMessage{..}
        send $ serializeMessage message
