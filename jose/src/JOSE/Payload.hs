module JOSE.Payload
    ( Payload (..)
    , makePayload
    , newPayload
    ) where

import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import Data.Time.Clock.POSIX (getPOSIXTime)
import Data.UUID (UUID)
import Data.UUID.V4 (nextRandom)
import GHC.Generics (Generic)
import Prelude hiding (exp)

data Payload = Payload
    { jti :: UUID
    , iss :: Text
    , sub :: UUID
    , exp :: Int
    , iat :: Int
    }
    deriving stock (Generic, Show)
    deriving anyclass (FromJSON, ToJSON)

makePayload :: UUID -> Text -> UUID -> Int -> Int -> Payload
makePayload = Payload

newPayload :: Text -> Int -> UUID -> IO Payload
newPayload iss ttl sub = do
    jti <- nextRandom
    iat <- round <$> getPOSIXTime
    let exp = ttl + iat
    pure Payload{..}
