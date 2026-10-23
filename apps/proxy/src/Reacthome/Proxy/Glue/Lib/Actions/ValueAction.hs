module Reacthome.Proxy.Glue.Lib.Actions.ValueAction where

import Control.Monad (void)
import Data.Aeson qualified as A
import Data.Text qualified as T
import Glue.Eval (Eval (..), liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Glue.IR qualified as IR
import Reacthome.Proxy.Bridge.Downstream (Downstream (..))
import Reacthome.Proxy.Daemon.Actions.Encode (encodeAction)
import Reacthome.Proxy.Daemon.Actions.Encode qualified as E

valueAction ::
    (?downstream :: Downstream) =>
    A.Value -> A.Key -> IR Eval
valueAction action key = NativeFunc (valueActionImpl action key)

valueActionImpl ::
    (?downstream :: Downstream) =>
    A.Value -> A.Key -> IR Eval -> Eval (IR Eval)
valueActionImpl action key = \case
    String uid -> matchId $ T.split (== '.') uid
    Symbol uid -> matchId $ T.split (== '.') uid
    DottedSymbol uid -> matchId uid
    _ -> errId
  where
    matchId ["proxy", uid] = do
        pure $ IR.NativeFunc (matchValue uid)
    matchId _ = errId

    matchValue uid = go uid . encodeAction

    go uid = \case
        Right value -> do
            void . liftIO $ ?downstream.send $ E.valueAction action key value uid
            pure Void
        Left e -> errValue e

    errId = throwError $ wrongArgumentType ["String `id` required"]
    errValue e = throwError $ wrongArgumentType [e]
