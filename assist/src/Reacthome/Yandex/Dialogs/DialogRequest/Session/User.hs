module Reacthome.Yandex.Dialogs.DialogRequest.Session.User
    ( User (..)
    ) where

import Data.Aeson (FromJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

newtype User = User
    { user_id :: Text
    }
    deriving stock (Generic, Show)
    deriving anyclass (FromJSON)
