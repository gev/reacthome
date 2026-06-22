module Reacthome.Proxy.Glue.Lib.Vision.Log where

import Data.Map qualified as M
import Data.UUID (UUID, toText)
import Glue.Eval (Eval, liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))

log ::
    (?session :: UUID) =>
    IR Eval
log = NativeFunc logImpl

logImpl ::
    (?session :: UUID) =>
    IR Eval -> Eval (IR Eval)
logImpl (Object pairs) = do
    case M.lookup "message" pairs of
        Just (String message) -> do
            let tag = case M.lookup "tag" pairs of
                    Just (String v) -> v
                    _ -> "info"
            liftIO . print $
                toText ?session
                    <> " "
                    <> tag
                    <> ": "
                    <> message
        _ -> pure ()

    pure Void
logImpl _ = throwError $ wrongArgumentType ["function requres `String` key parameters"]
