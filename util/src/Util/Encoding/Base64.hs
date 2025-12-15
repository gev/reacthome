module Util.Encoding.Base64
    ( decodeBase64
    , encodeBase64
    ) where

import Data.Bifunctor (first)
import Data.ByteString (ByteString)
import Data.ByteString.Base64 (decode, encode)
import Data.Text (Text)
import Util.Encoding.Error (EncodingError (Base64Error))
import Util.Encoding.Utf8 (decodeUtf8, encodeUtf8)

decodeBase64 :: Text -> Either EncodingError ByteString
decodeBase64 = first Base64Error . decode . encodeUtf8

encodeBase64 :: ByteString -> Either EncodingError Text
encodeBase64 = decodeUtf8 . encode
