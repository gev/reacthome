module Reacthome.Proxy.Glue.Lib.Vision where

import Data.UUID (UUID)
import Glue.Eval (Eval)
import Glue.Module (ModuleInfo, nativeModule)
import Reacthome.Proxy.Assets (Assets)
import Reacthome.Proxy.Glue.Lib.Vision.Download (download)
import Reacthome.Proxy.Glue.Lib.Vision.Log (log)
import Reacthome.Proxy.Glue.Lib.Vision.Subscribe (subscribe)
import Reacthome.Proxy.Glue.PubSub.Publisher (GluePublisher)
import Reacthome.Proxy.Sink (Sink)
import Prelude hiding (log)

vision ::
    ( ?session :: UUID
    , ?pubsub :: GluePublisher
    , ?assets :: Assets
    , ?sink :: Sink
    ) =>
    ModuleInfo Eval
vision =
    nativeModule
        "vision"
        [ ("subscribe", subscribe)
        , ("download", download)
        , ("log", log)
        ]
