module JOSE.JWK
    ( JWK (..)
    , fromJWK
    , toJWK
    ) where

import Data.Aeson (FromJSON (..), ToJSON (..), genericParseJSON, genericToJSON)
import Data.Bifunctor (first)
import Data.ByteArray.Encoding (Base (..), convertToBase)
import Data.Text (Text)
import Data.UUID (UUID)
import GHC.Generics (Generic)
import JOSE.Error (JoseError (..))
import JOSE.PublicKey (PublicKey (..), makePublicKey)
import JOSE.Util (aesonOptions)
import Util.Encoding.Base64.URL (decodeBase64Unpadded)
import Util.Encoding.Utf8 (decodeUtf8, encodeUtf8)

data JWK = JWK
    { kty :: Kty
    , crv :: Crv
    , x :: Text
    , kid :: UUID
    }
    deriving stock (Generic, Show)
    deriving anyclass (FromJSON, ToJSON)

data Kty = OKP
    deriving stock (Generic, Show)

instance FromJSON Kty where
    parseJSON = genericParseJSON aesonOptions

instance ToJSON Kty where
    toJSON = genericToJSON aesonOptions

data Crv = Ed25519
    deriving stock (Generic, Show)

instance FromJSON Crv where
    parseJSON = genericParseJSON aesonOptions

instance ToJSON Crv where
    toJSON = genericToJSON aesonOptions

fromJWK :: JWK -> Either JoseError PublicKey
fromJWK jwk =
    makePublicKey jwk.kid
        =<< first
            TokenPartDecodingError
            do decodeBase64Unpadded (encodeUtf8 jwk.x)

toJWK :: PublicKey -> Either JoseError JWK
toJWK pk = do
    let bs = convertToBase Base64URLUnpadded pk.publicKey
    x <- first TokenPartDecodingError (decodeUtf8 bs)
    pure
        JWK
            { kty = OKP
            , crv = Ed25519
            , x
            , kid = pk.kid
            }
