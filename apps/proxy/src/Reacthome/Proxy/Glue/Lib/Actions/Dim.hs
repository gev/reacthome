module Reacthome.Proxy.Glue.Lib.Actions.Dim where

import Control.Monad (void)
import Data.Text qualified as T
import Glue.Eval (Eval (..), liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Glue.IR qualified as IR
import Reacthome.Proxy.Bridge.Downstream (Downstream (..))
import Reacthome.Proxy.Daemon.Actions.Encode (actionDim)

dim :: (?downstream :: Downstream) => IR Eval
dim = NativeFunc dimImpl

dimImpl ::
    (?downstream :: Downstream) =>
    IR Eval -> Eval (IR Eval)
dimImpl = \case
    String key -> dimId $ T.split (== '.') key
    Symbol key -> dimId $ T.split (== '.') key
    DottedSymbol key -> dimId key
    _ -> errId
  where
    dimId ["proxy", uid] = do
        pure $ IR.NativeFunc (dimValue uid)
    dimId _ = errId

    dimValue uid (Float value) = go uid value
    dimValue uid (Integer value) = go uid $ fromIntegral value
    dimValue _ _ = errValue

    go uid value = do
        void . liftIO $ ?downstream.send $ actionDim uid value
        pure Void

    errId = throwError $ wrongArgumentType ["String `id` required"]
    errValue = throwError $ wrongArgumentType ["`Double` or `Integer` `value` required"]
