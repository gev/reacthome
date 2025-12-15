module Reacthome.Yandex.Dialogs.DialogRequest.Request.Markup
    ( Markup (..)
    ) where

import Data.Aeson (FromJSON)
import GHC.Generics (Generic)

newtype Markup = Markup
    { dangerous_context :: Bool
    }
    deriving stock (Generic, Show)
    deriving anyclass (FromJSON)
