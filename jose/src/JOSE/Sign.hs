module JOSE.Sign
    ( generateToken
    , signToken
    ) where

import Crypto.PubKey.Ed25519 qualified as Ed
import Data.Aeson (ToJSON, encode)
import Data.ByteArray.Encoding (Base (..), convertToBase)
import Data.ByteString (ByteString, toStrict)
import Data.Text (Text)
import Data.UUID (UUID)
import JOSE.Header (makeHeader)
import JOSE.JWT (Token (..), makeToken)
import JOSE.KeyPair (KeyPair (..))
import JOSE.Payload (newPayload)
import Util.Encoding.Base64.URL (encodeBase64Unpadded)

generateToken :: KeyPair -> Text -> Int -> UUID -> IO ByteString
generateToken kp iss ttl sub = do
    let header = makeHeader kp.kid
    payload <- newPayload iss ttl sub
    let token = makeToken header payload
    pure $ signToken kp token

signToken :: KeyPair -> Token -> ByteString
signToken kp token =
    message <> "." <> signature
  where
    header = code token.header
    payload = code token.payload
    message = header <> "." <> payload
    signature = convertToBase Base64URLUnpadded $ Ed.sign kp.secretKey kp.publicKey message

    code :: (ToJSON a) => a -> ByteString
    code = encodeBase64Unpadded . toStrict . encode
