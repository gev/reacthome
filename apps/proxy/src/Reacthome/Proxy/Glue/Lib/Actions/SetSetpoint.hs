module Reacthome.Proxy.Glue.Lib.Actions.SetSetpoint where

import Control.Monad (void)
import Data.Aeson.Key qualified as A
import Data.Text qualified as T
import Glue.Eval (Eval (..), liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Glue.IR qualified as IR
import Reacthome.Proxy.Bridge.Downstream (Downstream (..))
import Reacthome.Proxy.Daemon.Actions.Encode (actionSetpoint)

setSetpoint ::
    (?downstream :: Downstream) =>
    A.Key -> IR Eval
setSetpoint = NativeFunc . setSetpointImpl

setSetpointImpl ::
    (?downstream :: Downstream) =>
    A.Key -> IR Eval -> Eval (IR Eval)
setSetpointImpl setpoint ir = case ir of
    String key -> setSetpointId $ T.split (== '.') key
    Symbol key -> setSetpointId $ T.split (== '.') key
    DottedSymbol key -> setSetpointId key
    _ -> errId
  where
    setSetpointId ["proxy", uid] = do
        pure $ IR.NativeFunc (setSetpointValue uid)
    setSetpointId _ = errId

    setSetpointValue uid (Float value) = go uid value
    setSetpointValue uid (Integer value) = go uid $ fromIntegral value
    setSetpointValue _ _ = errValue

    go uid value = do
        void . liftIO $ ?downstream.send $ actionSetpoint setpoint uid value
        pure Void

    errId = throwError $ wrongArgumentType ["String `id` required"]
    errValue = throwError $ wrongArgumentType ["`Double` or `Integer` `value` required"]
