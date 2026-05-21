module Reacthome.Logic.Glue.Store where

import Control.Exception (SomeException, catch)
import Data.ByteString.Lazy qualified as L
import Data.Text (Text, unpack)

newtype GlueStore = GlueStore {get :: Text -> IO (Maybe L.ByteString)}

makeGlueStore :: String -> GlueStore
makeGlueStore folder =
    GlueStore
        { get = \name -> catch @SomeException
            do
                let file = folder <> unpack name <> ".glue"
                glue <- L.readFile file
                pure $ Just glue
            \err -> do
                print err
                pure Nothing
        }
