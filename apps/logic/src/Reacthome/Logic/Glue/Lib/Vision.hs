module Reacthome.Logic.Glue.Lib.Vision where

import Data.UUID (UUID)
import Glue.Eval (Eval)
import Glue.Module (ModuleInfo, nativeModule)
import Reacthome.Logic.Glue.Lib.Vision.Get (get)
import Reacthome.Logic.Glue.Lib.Vision.Log (log)
import Reacthome.Logic.Glue.Publisher (GluePublisher)
import Prelude hiding (log)

vision ::
    ( ?session :: UUID
    , ?pubsub :: GluePublisher
    ) =>
    ModuleInfo Eval
vision =
    nativeModule
        "vision"
        [ ("get", get)
        , ("log", log)
        ]
