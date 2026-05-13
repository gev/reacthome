module Reacthome.Logic.Glue.Sink where

import Data.ByteString.Lazy (ByteString)

type Sink = ByteString -> IO ()
