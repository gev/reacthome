module Reacthome.Assist.Repository.PublicKeys
    ( makePublicKeys
    ) where

import Control.Error (note)
import Data.HashMap.Strict (empty, fromList, lookup)
import Data.IORef (newIORef, readIORef, writeIORef)
import JOSE.PublicKey (PublicKey (kid), PublicKeys (..))
import Prelude hiding (lookup)

makePublicKeys :: IO (PublicKeys IO)
makePublicKeys = do
    jwks <- newIORef empty
    let
        findBy uid =
            note ("Public key " <> show uid <> " not found")
                . lookup uid
                <$> readIORef jwks
        store =
            writeIORef jwks
                . fromList
                . fmap \key -> (key.kid, key)
    pure
        PublicKeys{..}
