module Reacthome.Proxy.Daemon.Actions where

import Control.Monad ((<=<))
import Data.Aeson qualified as A
import Data.Aeson.Key qualified as A
import Data.Aeson.KeyMap qualified as A
import Data.Bifunctor (bimap)
import Data.ByteString.Lazy (ByteString)
import Data.Scientific (floatingOrInteger)
import Data.Text (Text)
import Data.Vector qualified as V
import Glue.AST (AST (..))

decodeAction :: ByteString -> Maybe AST
decodeAction = convert <=< A.decode

convert :: A.Object -> Maybe AST
convert o =
    lookupType o >>= \case
        "ACTION_SET" -> do
            id' <- lookupId o
            payload <- lookupPayload o
            pure $ makeObject id' payload
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

makeObject :: Text -> A.Object -> AST
makeObject id' payload = Object $ [("id", String id')] <> props payload

props :: A.Object -> [(Text, AST)]
props payload = bimap A.toText fromAeson <$> A.toList filtered
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
    , "value"
    , "site"
    , "parent"
    , "project"
    , "temperature"
    , "humidity"
    , "illumination"
    , "wheteher"
    , "timestamp"
    ]
