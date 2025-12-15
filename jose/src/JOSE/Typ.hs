module JOSE.Typ
    ( Typ (..)
    ) where

import Data.Aeson (FromJSON (..), ToJSON (..), genericParseJSON, genericToJSON)
import GHC.Generics (Generic)
import JOSE.Util (aesonOptions)

data Typ = JWT
    deriving stock (Generic, Show)

instance FromJSON Typ where
    parseJSON = genericParseJSON aesonOptions

instance ToJSON Typ where
    toJSON = genericToJSON aesonOptions
