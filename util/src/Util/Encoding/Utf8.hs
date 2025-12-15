module Util.Encoding.Utf8
    ( decodeUtf8
    , encodeUtf8
    ) where

import Data.Bifunctor (Bifunctor (first))
import Data.ByteString (ByteString)
import Data.Text (Text)
import Data.Text.Encoding qualified as T
import Util.Encoding.Error (EncodingError (..))

decodeUtf8 :: ByteString -> Either EncodingError Text
decodeUtf8 = first Utf8DecodeError . T.decodeUtf8'

encodeUtf8 :: Text -> ByteString
encodeUtf8 = T.encodeUtf8
