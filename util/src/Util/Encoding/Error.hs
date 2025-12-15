module Util.Encoding.Error
    ( EncodingError (..)
    ) where

import Control.Exception (Exception)
import Data.Text.Encoding.Error (UnicodeException)

data EncodingError
    = Utf8DecodeError UnicodeException
    | Base64DecodeError String
    | UUIDDecodeError
    deriving (Show, Exception)
