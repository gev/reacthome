module Reacthome.Proxy.Glue.Env where

import Data.UUID (UUID)
import Glue.Eval (Eval)
import Glue.IR (Env)
import Glue.Lib.Builtin (builtin)
import Glue.Module (envFromModules)
import Reacthome.Proxy.Assets (Assets)
import Reacthome.Proxy.Glue.Lib.Vision (vision)
import Reacthome.Proxy.Glue.Publisher (GluePublisher)
import Reacthome.Proxy.Sink (Sink)

env ::
    ( ?session :: UUID
    , ?pubsub :: GluePublisher
    , ?assets :: Assets
    , ?sink :: Sink
    ) =>
    Env Eval
env =
    envFromModules
        [ builtin
        , vision
        ]
