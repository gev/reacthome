module JOSE.Header
    ( Header (..)
    , makeHeader
    ) where

import Data.Aeson (FromJSON, ToJSON)
import Data.UUID (UUID)
import GHC.Generics (Generic)
import JOSE.Alg (Alg (..))
import JOSE.Typ (Typ (..))

data Header = Header
    { typ :: Typ
    , alg :: Alg
    , kid :: UUID
    }
    deriving stock (Generic, Show)
    deriving anyclass (FromJSON, ToJSON)

makeHeader :: UUID -> Header
makeHeader = Header JWT EdDSA
