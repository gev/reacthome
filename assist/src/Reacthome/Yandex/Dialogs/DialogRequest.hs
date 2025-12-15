module Reacthome.Yandex.Dialogs.DialogRequest
    ( DialogRequest (..)
    ) where

import Data.Aeson (FromJSON (..), withObject, (.:))
import Data.Aeson.KeyMap (member)
import Data.Text (Text)
import Reacthome.Yandex.Dialogs.DialogRequest.Meta (Meta)
import Reacthome.Yandex.Dialogs.DialogRequest.Request (Request)
import Reacthome.Yandex.Dialogs.DialogRequest.Session (Session)

data DialogRequest
    = DialogRequest
        { meta :: Meta
        , session :: Session
        , version :: Text
        , request :: Request
        }
    | LinkingComplete
        { meta :: Meta
        , session :: Session
        , version :: Text
        }
    deriving stock (Show)

instance FromJSON DialogRequest where
    parseJSON = withObject "DialogRequest" \v -> do
        let meta = v .: "meta"
            session = v .: "session"
            version = v .: "version"
        if member "account_linking_complete_event" v
            then
                LinkingComplete
                    <$> meta
                    <*> session
                    <*> version
            else
                DialogRequest
                    <$> meta
                    <*> session
                    <*> version
                    <*> v .: "request"
