module JOSE.Verify
    ( verifySignature
    ) where

import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Except (except, runExceptT, throwE)
import Crypto.Error (CryptoFailable (CryptoFailed, CryptoPassed))
import Crypto.PubKey.Ed25519 qualified as Ed
import Data.Bifunctor (first)
import Data.ByteString (ByteString)
import JOSE.Error (JoseError (..))
import JOSE.Header (Header (kid))
import JOSE.JWT (JWT (..), Token (..), parseToken, splitToken)
import JOSE.PublicKey (PublicKey (..), PublicKeys (..))
import Util.Encoding.Base64.URL (decodeBase64Unpadded)

verifySignature ::
    (Monad m) =>
    PublicKeys m ->
    ByteString ->
    m (Either JoseError Token)
verifySignature pks bs = runExceptT do
    jwt <- except (splitToken bs)
    token <- except (parseToken jwt)
    signature <- except (first TokenPartDecodingError $ decodeBase64Unpadded jwt.signature)
    case Ed.signature signature of
        CryptoFailed err -> throwE (InvalidSignatureFormat err)
        CryptoPassed sig -> do
            pk <- except =<< lift (pks.findBy token.header.kid)
            let msg = jwt.header <> "." <> jwt.payload
            if Ed.verify pk.publicKey msg sig
                then pure token
                else throwE InvalidSignature
