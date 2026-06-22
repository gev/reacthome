module Reacthome.Proxy.Glue.Lib.Vision where

import Data.UUID (UUID)
import Glue.Eval (Eval)
import Glue.Module (ModuleInfo, nativeModule)
import Reacthome.Proxy.Glue.Lib.Vision.Download (getAsset)
import Reacthome.Proxy.Glue.Lib.Vision.Log (log)
import Reacthome.Proxy.Glue.Lib.Vision.Subscribe (subscribe)
import Reacthome.Proxy.Glue.Publisher (GluePublisher)
import Reacthome.Proxy.Glue.Sink (Sink)
import Prelude hiding (log)

vision ::
    ( ?session :: UUID
    , ?pubsub :: GluePublisher
    , ?sink :: Sink
    ) =>
    ModuleInfo Eval
vision =
    nativeModule
        "vision"
        [ ("subscribe", subscribe)
        , ("get-asset", getAsset)
        , ("log", log)
        ]
