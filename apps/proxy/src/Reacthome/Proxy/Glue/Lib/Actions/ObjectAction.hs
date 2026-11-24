module Reacthome.Proxy.Glue.Lib.Actions.ObjectAction where

import Control.Monad (void)
import Data.Text (Text)
import Glue.Eval (Eval (..), liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Reacthome.Proxy.Bridge.Downstream (Downstream (..))
import Reacthome.Proxy.Daemon.Actions.Encode qualified as E

objectAction :: (?downstream :: Downstream) => Text -> IR Eval
objectAction = NativeFunc . abjectActionImpl

abjectActionImpl ::
    (?downstream :: Downstream) =>
    Text -> IR Eval -> Eval (IR Eval)
abjectActionImpl action = \case
    Object props -> do
        case E.encodeObject props of
            Right payload -> do
                void . liftIO $ ?downstream.send $ E.objectAction action payload
                pure Void
            Left err -> throwError $ wrongArgumentType [err]
    _ -> throwError $ wrongArgumentType ["Object `props` required"]
