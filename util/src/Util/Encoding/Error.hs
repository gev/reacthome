module Util.Encoding.Error
    ( EncodingError (..)
    ) where

import Data.Text.Encoding.Error (UnicodeException)

data EncodingError
    = Utf8Error UnicodeException
    | Base64Error String
