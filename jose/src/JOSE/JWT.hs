module JOSE.JWT
    ( JWT (..)
    , Token (..)
    , makeToken
    , splitToken
    , parseToken
    , isTokenValid
    , isTokenValidNow
    ) where

import Data.Aeson (FromJSON, eitherDecode)
import Data.Bifunctor (first)
import Data.ByteString.Char8 (ByteString, fromStrict, split)
import Data.Time.Clock.POSIX (POSIXTime, getPOSIXTime)
import JOSE.Error (JoseError (..))
import JOSE.Header (Header)
import JOSE.Payload (Payload (..))
import Util.Encoding.Base64.URL (decodeBase64)

data Token = Token
    { header :: Header
    , payload :: Payload
    }
    deriving stock (Show)

data JWT = JWT
    { header :: ByteString
    , payload :: ByteString
    , signature :: ByteString
    }

makeToken :: Header -> Payload -> Token
makeToken = Token

splitToken :: ByteString -> Either JoseError JWT
splitToken token = case split '.' token of
    [header, payload, signature] ->
        Right JWT{..}
    _ -> Left InvalidTokenFormat

parseToken :: JWT -> Either JoseError Token
parseToken token = do
    header <- decode HeaderJsonParseError token.header
    payload <- decode PayloadJsonParseError token.payload
    pure Token{..}
  where
    decode :: (FromJSON a) => (String -> JoseError) -> ByteString -> Either JoseError a
    decode err bs = do
        bs' <- first TokenPartDecodingError (decodeBase64 bs)
        first err (eitherDecode $ fromStrict bs')

isTokenValid :: Token -> POSIXTime -> Bool
isTokenValid token now = round now < token.payload.exp

isTokenValidNow :: Token -> IO Bool
isTokenValidNow token = isTokenValid token <$> getPOSIXTime
