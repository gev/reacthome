module Reacthome.Proxy.Glue.Lib.Actions.SimpleAction where

import Control.Monad (void)
import Data.Aeson qualified as A
import Data.Text qualified as T
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
    String uid -> go $ T.split (== '.') uid
    Symbol uid -> go $ T.split (== '.') uid
    DottedSymbol uid -> go uid
    _ -> err
  where
    go ["proxy", uid] = do
        void . liftIO $ ?downstream.send $ E.simpleAction action uid
        pure Void
    go _ = err

    err = throwError $ wrongArgumentType ["String `id` required"]
