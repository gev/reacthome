module Reacthome.Yandex.Dialogs.DialogResponse.Response
    ( Response (..)
    ) where

import Data.Aeson (ToJSON)
import Data.Text (Text)
import GHC.Generics (Generic)
import Reacthome.Yandex.Dialogs.DialogResponse.Response.Directives (Directives)

data Response = Response
    { text :: Text
    , tts :: Maybe Text
    , end_session :: Bool
    , directives :: Maybe Directives
    }
    deriving stock (Generic, Show)
    deriving anyclass (ToJSON)
