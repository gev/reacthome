module Reacthome.Proxy.Glue.Lib.Config where

import Glue.Eval (Eval)
import Glue.Module (ModuleInfo, nativeModule)
import Reacthome.Proxy.Glue.Lib.Config.App (appConfig)
import Prelude hiding (log)

vision :: ModuleInfo Eval
vision =
    nativeModule
        "proxy.config"
        [("app", appConfig)]
