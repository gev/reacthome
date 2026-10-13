module Reacthome.Proxy.Glue.Lib.Actions.ValueAction where

import Control.Monad (void)
import Data.Aeson qualified as A
import Data.Text qualified as T
import Glue.Eval (Eval (..), liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Glue.IR qualified as IR
import Reacthome.Proxy.Bridge.Downstream (Downstream (..))
import Reacthome.Proxy.Daemon.Actions.Encode qualified as E

valueAction ::
    (?downstream :: Downstream) =>
    A.Value -> A.Key -> IR Eval
valueAction action key = NativeFunc (valueActionImpl action key)

valueActionImpl ::
    (?downstream :: Downstream) =>
    A.Value -> A.Key -> IR Eval -> Eval (IR Eval)
valueActionImpl action key ir = case ir of
    String uid -> valueActionId $ T.split (== '.') uid
    Symbol uid -> valueActionId $ T.split (== '.') uid
    DottedSymbol uid -> valueActionId uid
    _ -> errId
  where
    valueActionId ["proxy", uid] = do
        pure $ IR.NativeFunc (matchValueAction uid)
    valueActionId _ = errId

    matchValueAction uid (Float value) = go uid value
    matchValueAction uid (Integer value) = go uid $ fromIntegral value
    matchValueAction _ _ = errValue

    go uid value = do
        void . liftIO $ ?downstream.send $ E.valueAction action key value uid
        pure Void

    errId = throwError $ wrongArgumentType ["String `id` required"]
    errValue = throwError $ wrongArgumentType ["`Double` or `Integer` `value` required"]
