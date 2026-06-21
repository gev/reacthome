module Reacthome.Logic.Glue.Lib.Vision where

import Data.UUID (UUID)
import Glue.Eval (Eval)
import Glue.Module (ModuleInfo, nativeModule)
import Reacthome.Logic.Glue.Lib.Vision.GetAsset (getAsset)
import Reacthome.Logic.Glue.Lib.Vision.Log (log)
import Reacthome.Logic.Glue.Lib.Vision.Subscribe (subscribe)
import Reacthome.Logic.Glue.Publisher (GluePublisher)
import Reacthome.Logic.Glue.Sink (Sink)
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
