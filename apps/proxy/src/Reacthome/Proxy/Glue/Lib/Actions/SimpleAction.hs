module Reacthome.Proxy.Glue.Lib.Actions.SimpleAction where

import Control.Monad (void)
import Data.Aeson qualified as A
import Glue.Eval (Eval (..), liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Reacthome.Proxy.Bridge.Downstream (Downstream (..))
import Reacthome.Proxy.Daemon.Actions.Encode qualified as E

simpleAction :: (?downstream :: Downstream) => A.Value -> IR Eval
simpleAction action = NativeFunc $ simpleActionImpl action

simpleActionImpl ::
    (?downstream :: Downstream) =>
    A.Value -> IR Eval -> Eval (IR Eval)
simpleActionImpl action = \case
    String uid -> go uid
    Symbol uid -> go uid
    DottedSymbol uid _ -> go uid
    _ -> err
  where
    go uid = do
        void . liftIO $ ?downstream.send $ E.simpleAction action uid
        pure Void

    err = throwError $ wrongArgumentType ["String `id` required"]
