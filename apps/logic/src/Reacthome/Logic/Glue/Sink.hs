module Reacthome.Logic.Glue.Sink where

import Data.ByteString (ByteString)

type Sink = ByteString -> IO ()
