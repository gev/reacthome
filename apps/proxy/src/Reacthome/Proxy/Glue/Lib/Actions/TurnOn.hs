module Reacthome.Proxy.Glue.Lib.Actions.TurnOn where

import Data.Aeson qualified as A
import Data.Aeson.KeyMap qualified as A
import Glue.Eval (Eval (..), liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Reacthome.Proxy.Bridge (Bridge (..), Downstream (..))

turnOn :: (?bridge :: Bridge) => IR Eval
turnOn = NativeFunc turnOnImpl

turnOnImpl ::
    (?bridge :: Bridge) => IR Eval -> Eval (IR Eval)
turnOnImpl = \case
    DottedSymbol ["proxy", uid] -> do
        let command =
                A.Object $
                    A.fromList
                        [ ("type", "ACTION_OFF")
                        , ("id", A.String uid)
                        ]
        let message = A.encode command
        liftIO $ ?bridge.downstream.send message
        pure Void
    _ -> throwError $ wrongArgumentType ["String `id` required"]
