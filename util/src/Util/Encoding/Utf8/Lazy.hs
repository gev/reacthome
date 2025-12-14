module Util.Encoding.Utf8.Lazy where

import Data.Bifunctor (first)
import Data.ByteString.Lazy (ByteString)
import Data.Text.Lazy (Text)
import Data.Text.Lazy.Encoding qualified as T
import Util.Encoding.Error (EncodingError (..))

decodeUtf8 :: ByteString -> Either EncodingError Text
decodeUtf8 = first Utf8Error . T.decodeUtf8'

encodeUtf8 :: Text -> ByteString
encodeUtf8 = T.encodeUtf8
