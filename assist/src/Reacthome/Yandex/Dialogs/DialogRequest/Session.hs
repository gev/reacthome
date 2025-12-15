module Reacthome.Yandex.Dialogs.DialogRequest.Session
    ( Session (..)
    ) where

import Data.Aeson (FromJSON)
import Data.Text (Text)
import GHC.Generics (Generic)
import Reacthome.Yandex.Dialogs.DialogRequest.Session.Application (Application)
import Reacthome.Yandex.Dialogs.DialogRequest.Session.User (User)

data Session = Session
    { message_id :: Int
    , session_id :: Text
    , skill_id :: Text
    , user :: User
    , application :: Application
    , new :: Bool
    , user_id :: Text
    }
    deriving stock (Generic, Show)
    deriving anyclass (FromJSON)
