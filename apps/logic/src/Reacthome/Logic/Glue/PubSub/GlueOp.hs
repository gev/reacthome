module Reacthome.Logic.Glue.PubSub.GlueOp where

import Data.ByteString.Lazy qualified as L

data GlueOp
    = Put L.ByteString
    | Patch L.ByteString
