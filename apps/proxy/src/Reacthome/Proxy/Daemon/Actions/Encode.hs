module Reacthome.Proxy.Daemon.Actions.Encode
where

import Data.Aeson qualified as A
import Data.Aeson.Key qualified as A
import Data.Aeson.KeyMap qualified as A
import Data.Map qualified as M
import Data.Scientific (fromFloatDigits)
import Data.Text (Text)
import Data.Text qualified as T
import Data.Vector qualified as V
import Glue.IR (IR (..))

{- | Encode IR to Aeson Value (reverse of fromAeson / decode)
Returns Left error for non-serializable IR types
-}
encodeAction :: IR m -> Either Text A.Value
encodeAction = \case
    Integer n -> Right (A.Number (fromIntegral n))
    Float n -> Right (A.Number (fromFloatDigits n))
    String s -> Right (A.String s)
    Bool b -> Right (A.Bool b)
    Symbol s -> Right (A.String s)
    DottedSymbol parts -> Right (A.String (T.intercalate "." parts))
    List xs -> A.Array . V.fromList <$> mapM encodeAction xs
    Object ps -> A.Object . A.fromList <$> mapM encodePair (M.toAscList ps)
    Void -> Left "Cannot encode Void"
    Evaluable{} -> Left "Cannot encode Evaluable"
    NativeValue{} -> Left "Cannot encode NativeValue"
    NativeFunc{} -> Left "Cannot encode NativeFunc"
    Special{} -> Left "Cannot encode Special"
    Closure{} -> Left "Cannot encode Closure"
  where
    encodePair (k, v) = case encodeAction v of
        Right val -> Right (A.fromText k, val)
        Left err -> Left err

getAction :: Text -> A.Object
getAction uid =
    A.fromList
        [ ("type", "get")
        , ("state", A.Array $ V.fromList [A.String uid])
        ]

simpleAction :: A.Value -> Text -> A.Object
simpleAction action uid =
    A.fromList
        [ ("type", action)
        , ("id", A.String uid)
        ]

valueAction :: A.Value -> A.Key -> A.Value -> Text -> A.Object
valueAction action key value uid =
    A.fromList
        [ ("type", action)
        , ("id", A.String uid)
        , (key, value)
        ]

minMaxAction :: A.Value -> Double -> Double -> Text -> A.Object
minMaxAction action minValue maxValue uid =
    A.fromList
        [ ("type", action)
        , ("id", A.String uid)
        , ("min", A.Number $ fromFloatDigits minValue)
        , ("max", A.Number $ fromFloatDigits maxValue)
        ]
