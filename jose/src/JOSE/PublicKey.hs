module JOSE.PublicKey
    ( PublicKey (..)
    , PublicKeys (..)
    , makePublicKey
    ) where

import Crypto.Error (CryptoFailable (..))
import Crypto.PubKey.Ed25519 qualified as Ed
import Data.ByteString (ByteString)
import Data.UUID (UUID)
import JOSE.Error (JoseError (..))

data PublicKey = PublicKey
    { kid :: UUID
    , publicKey :: Ed.PublicKey
    }
    deriving stock (Show)

data PublicKeys m = PublicKeys
    { findBy :: UUID -> m (Either JoseError PublicKey)
    , store :: [PublicKey] -> m ()
    }

makePublicKey :: UUID -> ByteString -> Either JoseError PublicKey
makePublicKey kid bs =
    case Ed.publicKey bs of
        CryptoFailed e -> Left (InvalidPublicKeyFormat e)
        CryptoPassed publicKey -> Right PublicKey{..}
