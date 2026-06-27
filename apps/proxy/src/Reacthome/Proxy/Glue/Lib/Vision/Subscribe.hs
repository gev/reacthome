module Reacthome.Proxy.Glue.Lib.Vision.Subscribe where

import Data.Text qualified as T
import Data.UUID (UUID)
import Glue.Eval (Eval, liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import PubSub.Publisher (Publisher (..))
import Reacthome.Proxy.Glue.PubSub.Types (GluePublisher)

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
subscribeImpl [String key, Integer value] = do
    liftIO $ ?pubsub.subscribe ?session (T.split (== '.') key) value
    pure Void
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
