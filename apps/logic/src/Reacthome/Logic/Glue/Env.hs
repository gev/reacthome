module Reacthome.Logic.Glue.Env where

import Data.UUID (UUID)
import Glue.Eval (Eval)
import Glue.IR (Env)
import Glue.Lib.Builtin (builtin)
import Glue.Module (envFromModules)
import Reacthome.Logic.Glue.Lib.Vision (vision)
import Reacthome.Logic.Glue.Publisher (GluePublisher)

env ::
    ( ?session :: UUID
    , ?pubsub :: GluePublisher
    ) =>
    Env Eval
env =
    envFromModules
        [ builtin
        , vision
        ]
