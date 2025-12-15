module Util.Encoding.UUID
    ( fromText
    , toText
    ) where

import Control.Error (note)
import Data.Text (Text)
import Data.UUID qualified as U
import Util.Encoding.Error (EncodingError (..))

toText :: U.UUID -> Text
toText = U.toText

fromText :: Text -> Either EncodingError U.UUID
fromText = note UUIDDecodeError . U.fromText
