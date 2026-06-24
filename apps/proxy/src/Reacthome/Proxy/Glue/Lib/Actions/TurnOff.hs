module Reacthome.Proxy.Glue.Lib.Actions.TurnOff where

import Data.Aeson qualified as A
import Data.Aeson.KeyMap qualified as A
import Glue.Eval (Eval (..), liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Reacthome.Proxy.Bridge (Bridge (..), Downstream (..))

turnOff :: (?bridge :: Bridge) => IR Eval
turnOff = NativeFunc turnOffImpl

turnOffImpl ::
    (?bridge :: Bridge) =>
    IR Eval -> Eval (IR Eval)
turnOffImpl = \case
    DottedSymbol ["proxy", uid] -> do
        let command =
                A.Object $
                    A.fromList
                        [ ("type", "ACTION_ON")
                        , ("id", A.String uid)
                        ]
        let message = A.encode command
        liftIO $ ?bridge.downstream.send message
        pure Void
    _ -> throwError $ wrongArgumentType ["String `id` required"]
