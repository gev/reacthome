module Reacthome.Logic.Glue.Lib.Vision where

import Glue.Eval (Eval)
import Glue.Module (ModuleInfo, nativeModule)
import Reacthome.Logic.Glue.Lib.Vision.Get
import Reacthome.Logic.Glue.Sink (Sink)

vision :: (?sink :: Sink) => ModuleInfo Eval
vision =
    nativeModule
        "vision"
        [ ("get", get)
        ]
