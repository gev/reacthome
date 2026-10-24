module Reacthome.Proxy.Glue.Lib.Actions where

import Glue.Eval (Eval)
import Glue.Module (ModuleInfo, nativeModule)
import Reacthome.Proxy.Bridge.Downstream (Downstream)
import Reacthome.Proxy.Glue.Lib.Actions.MinMaxAction (minMaxAction)
import Reacthome.Proxy.Glue.Lib.Actions.SimpleAction (simpleAction)
import Reacthome.Proxy.Glue.Lib.Actions.ValueAction (valueAction)

actions :: (?downstream :: Downstream) => ModuleInfo Eval
actions =
    nativeModule
        "proxy.actions"
        [ ("turn-on", simpleAction "ACTION_ON")
        , ("turn-off", simpleAction "ACTION_OFF")
        , ("dim", valueAction "ACTION_DIM" "value")
        , ("set-min-max-setpoint", minMaxAction "ACTION_SETPOINT_MIN_MAX")
        , ("set-temperature-setpoint", valueAction "ACTION_SETPOINT" "temperature")
        , ("set-humidity-setpoint", valueAction "ACTION_SETPOINT" "humidity")
        , ("set-co2-setpoint", valueAction "ACTION_SETPOINT" "co2")
        , ("start", simpleAction "ACTION_START")
        , ("stop", simpleAction "ACTION_STOP")
        , ("start-cool", simpleAction "ACTION_START_COOL")
        , ("stop-cool", simpleAction "ACTION_STOP_COOL")
        , ("set-cool-intensity", valueAction "ACTION_INTENSITY" "cool")
        , ("start-heat", simpleAction "ACTION_START_HEAT")
        , ("stop-heat", simpleAction "ACTION_STOP_HEAT")
        , ("set-heat-intensity", valueAction "ACTION_INTENSITY" "heat")
        , ("start-wet", simpleAction "ACTION_START_WET")
        , ("stop-wet", simpleAction "ACTION_STOP_WET")
        , ("start-dry", simpleAction "ACTION_START_DRY")
        , ("stop-dry", simpleAction "ACTION_STOP_DRY")
        , ("start-ventilation", simpleAction "ACTION_START_VENTILATION")
        , ("stop-ventilation", simpleAction "ACTION_STOP_VENTILATION")
        , ("set-ventilation-intensity", valueAction "ACTION_INTENSITY" "ventilation")
        , ("set-multiroom-zone-source", valueAction "ACTION_MULTIROOM_ZONE" "source")
        , ("reset-leakage", simpleAction "ACTION_LEAKAGE_RESET")
        , ("run-script", simpleAction "ACTION_SCRIPT_RUN")
        ]
