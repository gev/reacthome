module Reacthome.Assist.Domain.Query
    ( Query (..)
    ) where

import Data.Aeson (ToJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

data Query = Query
    { user_agent :: Text
    , skill :: Text
    , skill_user :: Text
    , skill_application :: Text
    , session :: Text
    , message :: Text
    }
    deriving stock (Generic, Show)
    deriving anyclass (ToJSON)
