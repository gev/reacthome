module Reacthome.Proxy.Daemon.Actions where

import Control.Monad ((<=<))
import Data.Aeson qualified as A
import Data.Aeson.Key qualified as A
import Data.Aeson.KeyMap qualified as A
import Data.Bifunctor (bimap)
import Data.ByteString.Lazy (ByteString)
import Data.Maybe (fromMaybe)
import Data.Scientific (floatingOrInteger, toBoundedInteger)
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
makeObject payload = bimap A.toText fromAeson <$> A.toList filtered
  where
    filtered = A.filterWithKey (const . (`elem` allowed)) payload

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

allowed :: [A.Key]
allowed =
    [ "type"
    , "title"
    , "code"
    , "bind"
    , "value"
    , "site"
    , "parent"
    , "project"
    , "temperature"
    , "humidity"
    , "illumination"
    , "wheteher"
    , "image"
    , "palette"
    , "scene"
    , "light_220"
    , "light_LED"
    , "light_RGB"
    , "curtains"
    , "leakage_sensor"
    , "valve_water"
    , "valve_heating"
    , "warm_floor"
    , "TV"
    , "AC"
    , "fan"
    , "socket_220"
    , "thermostat"
    , "multiroom"
    , "camera"
    , "intercom"
    , "hygrostat"
    , "co2_stat"
    , "din_rail"
    , "leakage"
    , "water_counter"
    , "electricity_meter"
    , "security"
    ]

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
