module Reacthome.Logic.Glue.Store where

import Control.Concurrent (forkIO, threadDelay)
import Control.Exception (SomeException, catch)
import Control.Monad (forever, void, when)
import Data.ByteString.Lazy qualified as L
import Data.List (intercalate)
import Data.Text (Text)
import Data.Text qualified as T
import System.Directory (canonicalizePath)
import System.FSNotify (Event (..), EventIsDirectory (..), watchTree, withManager)
import System.FilePath (pathSeparator, splitDirectories)

data GlueStore = GlueStore
    { get :: [Text] -> IO (Maybe L.ByteString)
    , runWatcher :: ([Text] -> L.ByteString -> IO ()) -> IO ()
    }

makeGlueStore :: FilePath -> GlueStore
makeGlueStore folder = GlueStore{..}
  where
    get parts = getFile $ folder <> intercalate [pathSeparator] (T.unpack <$> parts) <> ".glue"

    runWatcher publish = void . forkIO $ withManager \mgr -> do
        void $ watchTree mgr folder (const True) (handle publish)
        forever $ threadDelay 1_000_000

    handle publish (Modified path _ IsFile) = do
        getFile path >>= \case
            Nothing -> print $ "File not found: " <> path
            Just value -> do
                absolute <- canonicalizePath folder
                let file = drop (length absolute + 1) path
                let (key, ext) = splitAt (length file - 5) file
                when (ext == ".glue") do
                    let parts = splitDirectories key
                    publish (T.pack <$> parts) value
    handle _ _ = pure ()

    getFile file = catch @SomeException
        do
            glue <- L.readFile file
            pure $ Just glue
        \err -> do
            print err
            pure Nothing
