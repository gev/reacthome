module Reacthome.Proxy.Glue.Lib.Actions where

import Glue.Eval (Eval)
import Glue.Module (ModuleInfo, nativeModule)
import Reacthome.Proxy.Bridge.Downstream (Downstream)
import Reacthome.Proxy.Glue.Lib.Actions.Dim (dim)
import Reacthome.Proxy.Glue.Lib.Actions.SetSetpoint (setSetpoint)
import Reacthome.Proxy.Glue.Lib.Actions.TurnOff (turnOff)
import Reacthome.Proxy.Glue.Lib.Actions.TurnOn (turnOn)

actions :: (?downstream :: Downstream) => ModuleInfo Eval
actions =
    nativeModule
        "actions"
        [ ("turn-on", turnOn)
        , ("turn-off", turnOff)
        , ("dim", dim)
        , ("set-temperature-setpoint", setSetpoint "temperature")
        , ("set-humidity-setpoint", setSetpoint "humidity")
        , ("set-co2-setpoint", setSetpoint "co2")
        ]
