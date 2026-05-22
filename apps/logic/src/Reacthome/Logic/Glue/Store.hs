module Reacthome.Logic.Glue.Store where

import Control.Concurrent (forkIO, threadDelay)
import Control.Exception (SomeException, catch)
import Control.Monad (forever, void, when)
import Data.ByteString.Lazy qualified as L
import Data.Text (Text, pack, unpack)
import System.Directory (canonicalizePath)
import System.FSNotify (Event (..), EventIsDirectory (..), watchDir, withManager)

data GlueStore = GlueStore
    { get :: Text -> IO (Maybe L.ByteString)
    , runWatcher :: (Text -> L.ByteString -> IO ()) -> IO ()
    }

makeGlueStore :: String -> GlueStore
makeGlueStore folder = GlueStore{..}
  where
    get name = getFile $ folder <> unpack name <> ".glue"

    runWatcher publish = void . forkIO $ withManager \mgr -> do
        void $ watchDir mgr folder (const True) (handle publish)
        forever $ threadDelay 1_000_000

    handle publish (Modified path _ IsFile) =
        getFile path >>= \case
            Nothing -> print $ "File not found: " <> path
            Just value -> do
                absolute <- canonicalizePath folder
                let file = drop (length absolute + 1) path
                let (key, ext) = splitAt (length file - 5) file
                when (ext == ".glue") do
                    publish (pack key) value
    handle _ _ = pure ()

    getFile file = catch @SomeException
        do
            glue <- L.readFile file
            pure $ Just glue
        \err -> do
            print err
            pure Nothing
