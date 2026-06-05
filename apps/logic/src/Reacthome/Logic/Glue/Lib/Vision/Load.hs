module Reacthome.Logic.Glue.Lib.Vision.Load where

import Data.UUID (UUID)
import Glue.Eval (Eval, liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Reacthome.Logic.Glue.Publisher (GluePublisher)
import Reacthome.Logic.PubSub.Publisher (Publisher (..))

load ::
    ( ?session :: UUID
    , ?pubsub :: GluePublisher
    ) =>
    IR Eval
load = NativeFunc loadImpl

loadImpl ::
    ( ?session :: UUID
    , ?pubsub :: GluePublisher
    ) =>
    IR Eval -> Eval (IR Eval)
loadImpl (DottedSymbol key) = do
    liftIO $ ?pubsub.subscribe ?session key
    pure Void
loadImpl _ = throwError $ wrongArgumentType ["function requres `DottedSymbol` key parameters"]
