module Reacthome.Proxy.Glue.Lib.Vision.Subscribe where

import Data.UUID (UUID)
import Glue.Eval (Eval, liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import PubSub.Publisher (Publisher (..))
import Reacthome.Proxy.Glue.PubSub.GlueOp (GluePublisher)

subscribe ::
    ( ?session :: UUID
    , ?pubsub :: GluePublisher
    ) =>
    IR Eval
subscribe = Special subscribeImpl

subscribeImpl ::
    ( ?session :: UUID
    , ?pubsub :: GluePublisher
    ) =>
    [IR Eval] -> Eval (IR Eval)
subscribeImpl [Symbol key, Integer value] = do
    liftIO $ ?pubsub.subscribe ?session [key] value
    pure Void
subscribeImpl [DottedSymbol key, Integer value] = do
    liftIO $ ?pubsub.subscribe ?session key value
    pure Void
subscribeImpl _ =
    throwError $
        wrongArgumentType
            [ "Key parameter `Symbol` or `DottedSymbol`"
            , "Version parameter should ba `Integer`"
            ]
