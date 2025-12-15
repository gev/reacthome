module Reacthome.Yandex.Dialogs.DialogResponse
    ( DialogResponse (..)
    ) where

import Data.Aeson (ToJSON)
import Data.Text (Text)
import GHC.Generics (Generic)
import Reacthome.Yandex.Dialogs.DialogResponse.Response (Response)

data DialogResponse = DialogResponse
    { response :: Response
    , version :: Text
    }
    deriving stock (Generic, Show)
    deriving anyclass (ToJSON)
