module Reacthome.Yandex.Dialogs.DialogRequest.Session.Application
    ( Application (..)
    )
where

import Data.Aeson (FromJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

newtype Application = Application
    { application_id :: Text
    }
    deriving stock (Generic, Show)
    deriving anyclass (FromJSON)
