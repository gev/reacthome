module JOSE.JWKS
    ( JWKS (..)
    ) where

import Data.Aeson (FromJSON, ToJSON)
import GHC.Generics (Generic)
import JOSE.JWK (JWK)

newtype JWKS = JWKS
    { keys :: [JWK]
    }
    deriving stock (Generic, Show)
    deriving anyclass (FromJSON, ToJSON)
