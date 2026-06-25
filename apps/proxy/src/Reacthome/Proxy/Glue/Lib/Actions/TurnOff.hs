module Reacthome.Proxy.Glue.Lib.Actions.TurnOff where

import Glue.Eval (Eval (..), liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Reacthome.Proxy.Bridge.Downstream (Downstream (..))
import Reacthome.Proxy.Daemon.Actions (offAction)

turnOff :: (?downstream :: Downstream) => IR Eval
turnOff = NativeFunc turnOffImpl

turnOffImpl ::
    (?downstream :: Downstream) =>
    IR Eval -> Eval (IR Eval)
turnOffImpl = \case
    DottedSymbol ["proxy", uid] -> do
        liftIO $ ?downstream.send $ offAction uid
        pure Void
    _ -> throwError $ wrongArgumentType ["String `id` required"]
