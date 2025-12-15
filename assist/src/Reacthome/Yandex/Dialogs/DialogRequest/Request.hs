module Reacthome.Yandex.Dialogs.DialogRequest.Request
    ( Request (..)
    ) where

import Data.Aeson (FromJSON (..), genericParseJSON)
import Data.Text (Text)
import GHC.Generics (Generic)
import Reacthome.Yandex.Dialogs.DialogRequest.Request.Markup (Markup)
import Util.Aeson (typeFieldLabelModifier)

data Request = Request
    { command :: Text
    , original_utterance :: Text
    , markup :: Markup
    , type' :: Text
    }
    deriving stock (Generic, Show)

instance FromJSON Request where
    parseJSON = genericParseJSON typeFieldLabelModifier
