module Reacthome.Proxy.Glue.Lib.Actions.TurnOn where

import Control.Monad (void)
import Data.Text qualified as T
import Glue.Eval (Eval (..), liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Reacthome.Proxy.Bridge.Downstream (Downstream (..))
import Reacthome.Proxy.Daemon.Actions.Encode (actionOn)

turnOn :: (?downstream :: Downstream) => IR Eval
turnOn = NativeFunc turnOnImpl

turnOnImpl ::
    (?downstream :: Downstream) => IR Eval -> Eval (IR Eval)
turnOnImpl = \case
    String key -> go $ T.split (== '.') key
    Symbol key -> go $ T.split (== '.') key
    DottedSymbol key -> go key
    _ -> err
  where
    go ["proxy", uid] = do
        void . liftIO $ ?downstream.send $ actionOn uid
        pure Void
    go _ = err

    err = throwError $ wrongArgumentType ["String `id` required"]
