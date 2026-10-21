module Reacthome.Proxy.Glue.Lib.Actions.MinMaxAction where

import Control.Monad (void)
import Data.Aeson qualified as A
import Data.Text qualified as T
import Glue.Eval (Eval (..), liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Glue.IR qualified as IR
import Reacthome.Proxy.Bridge.Downstream (Downstream (..))
import Reacthome.Proxy.Daemon.Actions.Encode qualified as E

minMaxAction ::
    (?downstream :: Downstream) =>
    A.Value -> IR Eval
minMaxAction action = NativeFunc (minMaxActionImpl action)

minMaxActionImpl ::
    (?downstream :: Downstream) =>
    A.Value -> IR Eval -> Eval (IR Eval)
minMaxActionImpl action = \case
    String uid -> matchId $ T.split (== '.') uid
    Symbol uid -> matchId $ T.split (== '.') uid
    DottedSymbol uid -> matchId uid
    _ -> errId
  where
    matchId ["proxy", uid] = do
        pure $ IR.NativeFunc (matchMinValue uid)
    matchId _ = errId

    matchMinValue uid (Float minValue) = pure $ IR.NativeFunc (matchMaxValue uid minValue)
    matchMinValue uid (Integer minValue) = pure $ IR.NativeFunc (matchMaxValue uid $ fromIntegral minValue)
    matchMinValue _ _ = errValue

    matchMaxValue uid minValue (Float maxValue) = go uid minValue maxValue
    matchMaxValue uid minValue (Integer maxValue) = go uid minValue $ fromIntegral maxValue
    matchMaxValue _ _ _ = errValue

    go uid minValue maxValue = do
        void . liftIO $ ?downstream.send $ E.minMaxAction action minValue maxValue uid
        pure Void

    errId = throwError $ wrongArgumentType ["String `id` required"]
    errValue = throwError $ wrongArgumentType ["`Double` or `Integer` `value` required"]
