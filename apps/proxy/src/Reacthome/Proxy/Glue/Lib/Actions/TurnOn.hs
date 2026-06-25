module Reacthome.Proxy.Glue.Lib.Actions.TurnOn where

import Glue.Eval (Eval (..), liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Reacthome.Proxy.Bridge.Downstream (Downstream (..))
import Reacthome.Proxy.Daemon.Actions (onAction)

turnOn :: (?downstream :: Downstream) => IR Eval
turnOn = NativeFunc turnOnImpl

turnOnImpl ::
    (?downstream :: Downstream) => IR Eval -> Eval (IR Eval)
turnOnImpl = \case
    DottedSymbol ["proxy", uid] -> do
        liftIO $ ?downstream.send $ onAction uid
        pure Void
    _ -> throwError $ wrongArgumentType ["String `id` required"]
