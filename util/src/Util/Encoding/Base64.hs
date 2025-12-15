module Util.Encoding.Base64
    ( decodeBase64
    , encodeBase64
    ) where

import Data.Bifunctor (first)
import Data.ByteString (ByteString)
import Data.ByteString.Base64 (decode, encode)
import Util.Encoding.Error (EncodingError (..))

decodeBase64 :: ByteString -> Either EncodingError ByteString
decodeBase64 = first Base64DecodeError . decode

encodeBase64 :: ByteString -> ByteString
encodeBase64 = encode
