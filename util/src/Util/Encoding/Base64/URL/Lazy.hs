module Util.Encoding.Base64.URL.Lazy
    ( decodeBase64
    , encodeBase64
    ) where

import Data.Bifunctor (first)
import Data.ByteString.Base64.URL.Lazy (decodeUnpadded, encode)
import Data.ByteString.Lazy (ByteString)
import Data.Text.Lazy (Text)
import Util.Encoding.Error (EncodingError (..))
import Util.Encoding.Utf8.Lazy (decodeUtf8, encodeUtf8)

decodeBase64 :: Text -> Either EncodingError ByteString
decodeBase64 = first Base64DecodeError . decodeUnpadded . encodeUtf8

encodeBase64 :: ByteString -> Either EncodingError Text
encodeBase64 = decodeUtf8 . encode
