module Reacthome.Proxy.Glue.Env.Config where

import Glue.Eval (Eval)
import Glue.IR (Env)
import Glue.Module (envFromModules)
import Reacthome.Proxy.Glue.Lib.Config

configEnv :: Env Eval
configEnv = envFromModules [config]
