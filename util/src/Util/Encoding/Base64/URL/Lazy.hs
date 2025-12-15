module Util.Encoding.Base64.URL.Lazy
    ( decodeBase64
    , encodeBase64
    , decodeBase64Unpadded
    , encodeBase64Unpadded
    ) where

import Data.Bifunctor (first)
import Data.ByteString.Base64.URL.Lazy (decode, decodeUnpadded, encode, encodeUnpadded)
import Data.ByteString.Lazy (ByteString)
import Util.Encoding.Error (EncodingError (..))

decodeBase64 :: ByteString -> Either EncodingError ByteString
decodeBase64 = first Base64DecodeError . decode

decodeBase64Unpadded :: ByteString -> Either EncodingError ByteString
decodeBase64Unpadded = first Base64DecodeError . decodeUnpadded

encodeBase64 :: ByteString -> ByteString
encodeBase64 = encode

encodeBase64Unpadded :: ByteString -> ByteString
encodeBase64Unpadded = encodeUnpadded
