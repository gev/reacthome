module Reacthome.Yandex.Dialogs.DialogRequest.Meta
    ( Meta (..)
    ) where

import Data.Aeson (FromJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

data Meta = Meta
    { locale :: Text
    , timezone :: Text
    , client_id :: Text
    }
    deriving stock (Generic, Show)
    deriving anyclass (FromJSON)
