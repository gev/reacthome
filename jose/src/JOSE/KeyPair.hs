module JOSE.KeyPair
    ( KeyPair (..)
    , makeKeyPair
    , generateKeyPair
    ) where

import Crypto.Error (CryptoFailable (..))
import Crypto.PubKey.Ed25519 qualified as Ed
import Data.ByteString (ByteString)
import Data.UUID (UUID)
import Data.UUID.V4 (nextRandom)
import JOSE.Error (JoseError (..))

data KeyPair = KeyPair
    { kid :: UUID
    , secretKey :: Ed.SecretKey
    , publicKey :: Ed.PublicKey
    }
    deriving stock (Show)

makeKeyPair :: UUID -> ByteString -> Either JoseError KeyPair
makeKeyPair kid bs = do
    case Ed.secretKey bs of
        CryptoFailed err -> Left $ InvalidSecretKeyFormat err
        CryptoPassed secretKey -> Right $ fromSecret kid secretKey

generateKeyPair :: IO KeyPair
generateKeyPair = do
    kid <- nextRandom
    fromSecret kid <$> Ed.generateSecretKey

fromSecret :: UUID -> Ed.SecretKey -> KeyPair
fromSecret kid secretKey =
    KeyPair
        { kid
        , secretKey
        , publicKey = Ed.toPublic secretKey
        }
