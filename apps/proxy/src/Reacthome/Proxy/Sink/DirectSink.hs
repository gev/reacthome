module Reacthome.Proxy.Sink.DirectSink where

import Reacthome.Relay (LazyRaw)

newtype DirectSink = DirectSink
    { send :: LazyRaw -> IO ()
    }

makeDirectSink :: (LazyRaw -> IO ()) -> DirectSink
makeDirectSink = DirectSink
