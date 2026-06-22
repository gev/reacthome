module Reacthome.Proxy.Glue.Lib.Vision.Download where

import Glue.Eval (Eval, liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Reacthome.Proxy.Assets (Assets (..))
import Reacthome.Proxy.Sink (Sink)

download ::
    ( ?assets :: Assets
    , ?sink :: Sink
    ) =>
    IR Eval
download = Special downloadImpl

downloadImpl ::
    ( ?assets :: Assets
    , ?sink :: Sink
    ) =>
    [IR Eval] -> Eval (IR Eval)
downloadImpl [Symbol key] = do
    liftIO $ ?assets.sendAsset ?sink [key]
    pure Void
downloadImpl [DottedSymbol key] = do
    liftIO $ ?assets.sendAsset ?sink key
    pure Void
downloadImpl _ =
    throwError $
        wrongArgumentType
            ["Name parameter should be `Symbol` or `DottedSymbol`"]
