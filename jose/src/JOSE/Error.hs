module JOSE.Error
    ( JoseError (..)
    ) where

import Control.Exception.Base (Exception)
import Crypto.Error (CryptoError)
import Data.Text (Text)
import Data.UUID (UUID)
import Util.Encoding.Error (EncodingError)

data JoseError
    = InvalidTokenFormat
    | TokenPartDecodingError EncodingError
    | HeaderJsonParseError String
    | PayloadJsonParseError String
    | InvalidPublicKeyFormat CryptoError
    | InvalidSecretKeyFormat CryptoError
    | InvalidSignatureFormat CryptoError
    | InvalidSignature
    | -- ToDo: Use next JOSE errors
      UnsupportedHeaderType
    | UnsupportedAlgorithm
    | KeyNotFound UUID
    | TokenExpired
    | TokenNotYetValid
    | InvalidIssuer Text
    deriving (Show, Exception)
