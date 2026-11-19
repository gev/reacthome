module Reacthome.Proxy.Glue.Store where

import Control.Concurrent (forkIO, threadDelay)
import Control.Concurrent.Chan.Unagi.Bounded (newChan, readChan, writeChan)
import Control.Exception (SomeException, catch)
import Control.Monad (foldM, forever, void, when)
import Data.ByteString.Lazy qualified as L
import Data.IORef (newIORef, readIORef)
import Data.Map qualified as M
import Data.Text qualified as T
import Data.Time.Clock (UTCTime)
import Data.Time.Clock.POSIX (utcTimeToPOSIXSeconds)
import PubSub.Revision (Revision (..))
import Reacthome.Proxy.Glue.PubSub.Types (GlueLookup, GluePublish)
import System.Directory (canonicalizePath, doesDirectoryExist, getModificationTime, listDirectory)
import System.FSNotify (Event (..), EventIsDirectory (..), watchTree, withManager)
import System.FilePath (dropExtension, pathSeparator, takeExtension, (</>))
import Prelude hiding (lookup)

data GlueStore = GlueStore
    { lookup :: GlueLookup
    , runWatcher :: GluePublish
    }

makeGlueStore :: FilePath -> IO GlueStore
makeGlueStore folder = do
    index <- newIORef =<< buildIndex folder

    let
        lookup key = do
            index' <- readIORef index
            case M.lookup key index' of
                Nothing -> pure Nothing
                Just file ->
                    catch @SomeException
                        do
                            payload <- L.readFile file
                            version <- utcTimeToMillis <$> getModificationTime file
                            pure $ Just Revision{..}
                        \err -> do
                            print err
                            pure Nothing

        runWatcher publish = withManager \mgr -> do
            (inChan, outChan) <- newChan 1_000

            void . forkIO $ forever do
                handle publish =<< readChan outChan

            void $ watchTree mgr folder (const True) (writeChan inChan)
            forever $ threadDelay 1_000_000

        -- ToDo: update index: add new files and remove deleted
        handle publish (Modified path time IsFile) = send publish path time
        -- handle publish (Added path time IsFile) = send publish path time
        handle _ _ = pure ()

        send publish path time = catch @SomeException
            do
                absolute <- canonicalizePath folder
                let file = drop (length absolute + 1) path
                let (key, ext) = splitAt (length file - 5) file
                when (ext == ".glue") do
                    payload <- L.readFile path
                    let version = utcTimeToMillis time
                    let value = Revision{..}
                    publish (T.pack $ replace pathSeparator '.' key) value
            \err -> do
                print err
                pure ()

    pure GlueStore{..}

utcTimeToMillis :: UTCTime -> Int
utcTimeToMillis utc = round $ utcTimeToPOSIXSeconds utc * 1000

replace :: (Eq a) => a -> a -> [a] -> [a]
replace old new = map (\x -> if x == old then new else x)

buildIndex :: FilePath -> IO (M.Map T.Text FilePath)
buildIndex root = go root
  where
    go folder = do
        entries <- listDirectory folder
        foldM (addEntry folder) M.empty entries

    addEntry folder index entry = do
        let path = folder </> entry
        isDirectory <- doesDirectoryExist path
        if isDirectory
            then do
                nested <- go path
                pure $ M.union index nested
            else
                if takeExtension entry == ".glue"
                    then do
                        let relative = drop (length root + 1) path
                            keyPath = dropExtension relative
                            key = T.pack $ replace pathSeparator '.' keyPath
                        pure $ M.insert key path index
                    else pure index
