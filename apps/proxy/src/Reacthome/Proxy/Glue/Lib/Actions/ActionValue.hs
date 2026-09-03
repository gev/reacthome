module Reacthome.Proxy.Glue.Lib.Actions.ActionValue where

import Control.Monad (void)
import Data.Aeson qualified as A
import Data.Text qualified as T
import Glue.Eval (Eval (..), liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Glue.IR qualified as IR
import Reacthome.Proxy.Bridge.Downstream (Downstream (..))
import Reacthome.Proxy.Daemon.Actions.Encode qualified as E

actionValue ::
    (?downstream :: Downstream) =>
    A.Value -> A.Key -> IR Eval
actionValue action key = NativeFunc (actionValueImpl action key)

actionValueImpl ::
    (?downstream :: Downstream) =>
    A.Value -> A.Key -> IR Eval -> Eval (IR Eval)
actionValueImpl action key ir = case ir of
    String uid -> actionValueId $ T.split (== '.') uid
    Symbol uid -> actionValueId $ T.split (== '.') uid
    DottedSymbol uid -> actionValueId uid
    _ -> errId
  where
    actionValueId ["proxy", uid] = do
        pure $ IR.NativeFunc (matchActionValue uid)
    actionValueId _ = errId

    matchActionValue uid (Float value) = go uid value
    matchActionValue uid (Integer value) = go uid $ fromIntegral value
    matchActionValue _ _ = errValue

    go uid value = do
        void . liftIO $ ?downstream.send $ E.actionValue action key value uid
        pure Void

    errId = throwError $ wrongArgumentType ["String `id` required"]
    errValue = throwError $ wrongArgumentType ["`Double` or `Integer` `value` required"]
