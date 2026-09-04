module Reacthome.Proxy.Glue.Lib.Actions where

import Glue.Eval (Eval)
import Glue.Module (ModuleInfo, nativeModule)
import Reacthome.Proxy.Bridge.Downstream (Downstream)
import Reacthome.Proxy.Glue.Lib.Actions.ActionState (actionState)
import Reacthome.Proxy.Glue.Lib.Actions.ActionValue (actionValue)

actions :: (?downstream :: Downstream) => ModuleInfo Eval
actions =
    nativeModule
        "actions"
        [ ("turn-on", actionState "ACTION_ON")
        , ("turn-off", actionState "ACTION_OFF")
        , ("dim", actionValue "ACTION_DIM" "value")
        , ("set-temperature-setpoint", actionValue "ACTION_SETPOINT" "temperature")
        , ("set-humidity-setpoint", actionValue "ACTION_SETPOINT" "humidity")
        , ("set-co2-setpoint", actionValue "ACTION_SETPOINT" "co2")
        , ("start", actionState "ACTION_START")
        , ("stop", actionState "ACTION_STOP")
        , ("start-cool", actionState "ACTION_START_COOL")
        , ("stop-cool", actionState "ACTION_STOP_COOL")
        , ("set-cool-intensity", actionValue "ACTION_INTENSITY" "cool")
        , ("start-heat", actionState "ACTION_START_HEAT")
        , ("stop-heat", actionState "ACTION_STOP_HEAT")
        , ("set-heat-intensity", actionValue "ACTION_INTENSITY" "heat")
        , ("start-wet", actionState "ACTION_START_WET")
        , ("stop-wet", actionState "ACTION_STOP_WET")
        , ("start-dry", actionState "ACTION_START_DRY")
        , ("stop-dry", actionState "ACTION_STOP_DRY")
        , ("start-ventilation", actionState "ACTION_START_VENTILATION")
        , ("stop-ventilation", actionState "ACTION_STOP_VENTILATION")
        , ("set-ventilation-intensity", actionValue "ACTION_INTENSITY" "ventilation")
        ]
