module Reacthome.Proxy.Sink where

import Reacthome.Proxy.Sink.DirectSink (DirectSink (..))
import Reacthome.Proxy.Sink.RelaySink (RelaySink (..))
import Reacthome.Relay (LazyRaw)

newtype Sink = Sink
    { send :: LazyRaw -> IO ()
    }

fromDirectSink :: DirectSink -> Sink
fromDirectSink sink = Sink sink.send

fromRelaySink :: RelaySink -> Sink
fromRelaySink sink = Sink sink.send
