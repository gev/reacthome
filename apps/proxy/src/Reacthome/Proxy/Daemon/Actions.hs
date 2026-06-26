module Reacthome.Proxy.Daemon.Actions where

import Control.Monad ((<=<))
import Data.Aeson qualified as A
import Data.Aeson.Key qualified as A
import Data.Aeson.KeyMap qualified as A
import Data.Bifunctor (bimap)
import Data.ByteString.Lazy (ByteString)
import Data.Maybe (fromMaybe)
import Data.Scientific (floatingOrInteger, toBoundedInteger, toRealFloat)
import Data.Text (Text)
import Data.Vector qualified as V
import Glue.AST (AST (..))

decodeAction :: ByteString -> Maybe (Text, [(Text, AST)], Int)
decodeAction = convert <=< A.decode

convert :: A.Object -> Maybe (Text, [(Text, AST)], Int)
convert o =
    lookupType o >>= \case
        "ACTION_SET" -> do
            id' <- lookupId o
            payload <- lookupPayload o
            let timestamp = lookupTimestamp payload
            pure (id', makeObject payload, timestamp)
        _ -> Nothing

lookupType :: A.Object -> Maybe Text
lookupType = lookupString "type"

lookupId :: A.Object -> Maybe Text
lookupId = lookupString "id"

lookupString :: A.Key -> A.Object -> Maybe Text
lookupString name o =
    A.lookup name o >>= \case
        A.String t -> pure t
        _ -> Nothing

lookupPayload :: A.Object -> Maybe A.Object
lookupPayload o =
    A.lookup "payload" o >>= \case
        A.Object p -> pure p
        _ -> Nothing

lookupTimestamp :: A.Object -> Int
lookupTimestamp o =
    let sci =
            case A.lookup "timestamp" o of
                Just (A.Number n) -> toBoundedInteger n
                _ -> Nothing
     in fromMaybe 0 sci

makeObject :: A.Object -> [(Text, AST)]
makeObject payload =
    [ (A.toText k, ast)
    | (k, v) <- A.toList payload
    , Just ast <- [processKey k v]
    ]

fromAeson :: A.Value -> AST
fromAeson = \case
    A.Object o -> Object $ bimap A.toText fromAeson <$> A.toList o
    A.Array a -> List $ fromAeson <$> V.toList a
    A.String t -> String t
    A.Number n -> case floatingOrInteger n of
        Left f -> Float f
        Right i -> Integer i
    A.Bool b -> Symbol (if b then "true" else "false")
    A.Null -> Symbol "nil"

processKey :: A.Key -> A.Value -> Maybe AST
-- Process as String
processKey "type" = processKeyString
processKey "title" = processKeyString
processKey "code" = processKeyString
processKey "image" = processKeyString
-- Process as Boolean
processKey "enabled" = processKeyBoolean
processKey "disabled" = processKeyBoolean
processKey "dimmable" = processKeyBoolean
-- Process as Float
processKey "temperature" = processKeyFloat
processKey "humidity" = processKeyFloat
processKey "illumination" = processKeyFloat
-- Process as Value
processKey "value" = processKeyValue
-- Process as Reference
processKey "bind" = processKeyReference
processKey "site" = processKeyReference
processKey "parent" = processKeyReference
processKey "project" = processKeyReference
processKey "scene" = processKeyReference
processKey "light_220" = processKeyReference
processKey "light_LED" = processKeyReference
processKey "light_RGB" = processKeyReference
processKey "curtains" = processKeyReference
processKey "leakage_sensor" = processKeyReference
processKey "valve_water" = processKeyReference
processKey "valve_heating" = processKeyReference
processKey "warm_floor" = processKeyReference
processKey "TV" = processKeyReference
processKey "AC" = processKeyReference
processKey "fan" = processKeyReference
processKey "socket_220" = processKeyReference
processKey "thermostat" = processKeyReference
processKey "multiroom" = processKeyReference
processKey "camera" = processKeyReference
processKey "intercom" = processKeyReference
processKey "hygrostat" = processKeyReference
processKey "co2_stat" = processKeyReference
processKey "din_rail" = processKeyReference
processKey "leakage" = processKeyReference
processKey "water_counter" = processKeyReference
processKey "electricity_meter" = processKeyReference
processKey "security" = processKeyReference
-- Process as default
processKey "palette" = processKeyDefault
processKey "weather" = processKeyDefault
-- Skipp other
processKey _ = const Nothing

processKeyString :: A.Value -> Maybe AST
processKeyString (A.String str) = Just $ String str
processKeyString _ = Nothing

processKeyBoolean :: A.Value -> Maybe AST
processKeyBoolean (A.Bool b) = Just $ Symbol if b then "true" else "false"
processKeyBoolean _ = Nothing

processKeyFloat :: A.Value -> Maybe AST
processKeyFloat (A.Number sci) = Just $ Float (toRealFloat sci)
processKeyFloat _ = Nothing

processKeyValue :: A.Value -> Maybe AST
processKeyValue (A.Number sci) = Just $ Float (toRealFloat sci)
processKeyValue (A.Bool b) = Just $ Symbol if b then "true" else "false"
processKeyValue _ = Nothing

processKeyReference :: A.Value -> Maybe AST
processKeyReference (A.String ref) = Just $ reference ref
processKeyReference (A.Array val) = Just $ List [reference ref | (A.String ref) <- V.toList val]
processKeyReference _ = Nothing

reference :: Text -> AST
reference ref = Symbol ("'proxy." <> ref)

processKeyDefault :: A.Value -> Maybe AST
processKeyDefault = Just . fromAeson

getAction :: Text -> A.Object
getAction uid =
    A.fromList
        [ ("type", "get")
        , ("state", A.Array $ V.fromList [A.String uid])
        ]

onAction :: Text -> A.Object
onAction uid =
    A.fromList
        [ ("type", "ACTION_ON")
        , ("id", A.String uid)
        ]

offAction :: Text -> A.Object
offAction uid =
    A.fromList
        [ ("type", "ACTION_OFF")
        , ("id", A.String uid)
        ]
