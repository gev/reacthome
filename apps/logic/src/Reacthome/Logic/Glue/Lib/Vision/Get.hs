module Reacthome.Logic.Glue.Lib.Vision.Get where

import Data.UUID (UUID)
import Glue.Eval (Eval, liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Reacthome.Logic.Glue.Publisher (GluePublisher)
import Reacthome.Logic.PubSub.Publisher (Publisher (..))

get ::
    ( ?session :: UUID
    , ?pubsub :: GluePublisher
    ) =>
    IR Eval
get = Special getImpl

getImpl ::
    ( ?session :: UUID
    , ?pubsub :: GluePublisher
    ) =>
    [IR Eval] -> Eval (IR Eval)
getImpl [Symbol key, Integer value] = do
    liftIO $ ?pubsub.subscribe ?session [key] value
    pure Void
getImpl [DottedSymbol key, Integer value] = do
    liftIO $ ?pubsub.subscribe ?session key value
    pure Void
getImpl _ = throwError $ wrongArgumentType ["function requres `Symbol` or `DottedSymbol` key parameters"]
