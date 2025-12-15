module Reacthome.Assist.Service.JOSE.PublicKey
    ( runPublicKeysUpdate
    ) where

import Control.Concurrent (forkIO, threadDelay)
import Control.Error.Util (exceptT)
import Control.Monad (forever, void)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Except (except)
import Data.Aeson (eitherDecode)
import Data.Bifunctor (Bifunctor (first))
import JOSE.JWK (fromJWK)
import JOSE.JWKS (JWKS (..))
import JOSE.PublicKey (PublicKeys (..))
import Network.HTTP.Client (Response (..), httpLbs, newManager, parseRequest)
import Network.HTTP.Client.TLS (tlsManagerSettings)
import Reacthome.Assist.Environment (Environment (..))

runPublicKeysUpdate ::
    ( ?environment :: Environment
    , ?publicKeys :: PublicKeys IO
    ) =>
    IO ()
runPublicKeysUpdate = do
    req <- parseRequest ?environment.jwksURL
    manager <- newManager tlsManagerSettings
    let updatePublicKeys = do
            {-
                TODO: Handle the HTTP response status code
            -}
            response <- lift $ responseBody <$> httpLbs req manager
            jwks <- except (eitherDecode @JWKS response)
            keys <- except (traverse (first show . fromJWK) jwks.keys)
            lift (?publicKeys.store keys)

    void . forkIO . forever $ exceptT error pure do
        updatePublicKeys
        lift (threadDelay $ 1_000_000 * ?environment.publicKeysUpdateInterval)
