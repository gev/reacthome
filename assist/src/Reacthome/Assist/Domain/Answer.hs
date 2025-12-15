module Reacthome.Assist.Domain.Answer
    ( AnswerID
    , Answer (..)
    ) where

import Data.Aeson (FromJSON (..), genericParseJSON)
import Data.Text (Text)
import Data.UUID (UUID)
import GHC.Generics (Generic)
import Util.Aeson (omitNothing)

type AnswerID = UUID

data Answer = Answer
    { message :: Text
    , session :: Text
    , end :: Maybe Bool
    }
    deriving stock (Generic, Show)

instance FromJSON Answer where
    parseJSON = genericParseJSON omitNothing
