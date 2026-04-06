module Reacthome.Logic.Glue.Env where

import Glue.Eval (Eval)
import Glue.IR (Env)
import Glue.Module (envFromModule)
import Reacthome.Logic.Glue.Lib.Vision (vision)
import Reacthome.Logic.Glue.Sink (Sink)

env :: (?sink :: Sink) => Env Eval
env = envFromModule vision
