module Reacthome.Proxy.Glue.Lib.Actions.TurnOff where

import Control.Monad (void)
import Data.Text qualified as T
import Glue.Eval (Eval (..), liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Reacthome.Proxy.Bridge.Downstream (Downstream (..))
import Reacthome.Proxy.Daemon.Actions.Encode (actionOff)

turnOff :: (?downstream :: Downstream) => IR Eval
turnOff = NativeFunc turnOffImpl

turnOffImpl ::
    (?downstream :: Downstream) =>
    IR Eval -> Eval (IR Eval)
turnOffImpl = \case
    String key -> go $ T.split (== '.') key
    Symbol key -> go $ T.split (== '.') key
    DottedSymbol key -> go key
    _ -> err
  where
    go ["proxy", uid] = do
        void . liftIO $ ?downstream.send $ actionOff uid
        pure Void
    go _ = err

    err = throwError $ wrongArgumentType ["String `id` required"]
