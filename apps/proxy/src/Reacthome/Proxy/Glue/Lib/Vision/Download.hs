module Reacthome.Proxy.Glue.Lib.Vision.Download where

import Glue.Eval (Eval, liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Reacthome.Proxy.Assets (sendAsset)
import Reacthome.Proxy.Sink (Sink)

getAsset ::
    (?sink :: Sink) =>
    IR Eval
getAsset = Special getAssetImpl

getAssetImpl ::
    (?sink :: Sink) =>
    [IR Eval] -> Eval (IR Eval)
getAssetImpl [Symbol key] = do
    liftIO $ sendAsset [key]
    pure Void
getAssetImpl [DottedSymbol key] = do
    liftIO $ sendAsset key
    pure Void
getAssetImpl _ =
    throwError $
        wrongArgumentType
            ["Name parameter should be `Symbol` or `DottedSymbol`"]
