module Reacthome.Proxy.Glue.Lib.Actions where

import Glue.Eval (Eval)
import Glue.Module (ModuleInfo, nativeModule)
import Reacthome.Proxy.Bridge.Downstream (Downstream)
import Reacthome.Proxy.Glue.Lib.Actions.Dim (dim)
import Reacthome.Proxy.Glue.Lib.Actions.TurnOff (turnOff)
import Reacthome.Proxy.Glue.Lib.Actions.TurnOn (turnOn)

actions :: (?downstream :: Downstream) => ModuleInfo Eval
actions =
    nativeModule
        "actions"
        [ ("on", turnOn)
        , ("off", turnOff)
        , ("dim", dim)
        ]
