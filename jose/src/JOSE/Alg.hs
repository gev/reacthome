module JOSE.Alg
    ( Alg (..)
    ) where

import Data.Aeson (FromJSON (..), ToJSON (..), genericParseJSON, genericToJSON)
import GHC.Generics (Generic)
import JOSE.Util (aesonOptions)

data Alg = EdDSA
    deriving stock (Generic, Eq, Show)

instance FromJSON Alg where
    parseJSON = genericParseJSON aesonOptions

instance ToJSON Alg where
    toJSON = genericToJSON aesonOptions
