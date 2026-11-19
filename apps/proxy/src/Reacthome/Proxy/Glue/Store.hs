module Reacthome.Proxy.Glue.Store where

import Control.Concurrent (forkIO, threadDelay)
import Control.Concurrent.Chan.Unagi.Bounded (newChan, readChan, writeChan)
import Control.Exception (SomeException, catch)
import Control.Monad (foldM, forever, void)
import Data.ByteString.Lazy qualified as L
import Data.IORef (atomicModifyIORef', newIORef, readIORef, writeIORef)
import Data.Map qualified as M
import Data.Text qualified as T
import Data.Time.Clock (UTCTime)
import Data.Time.Clock.POSIX (utcTimeToPOSIXSeconds)
import PubSub.Revision (Revision (..))
import Reacthome.Proxy.Glue.PubSub.Types (GlueLookup, GluePublish)
import System.Directory (canonicalizePath, doesDirectoryExist, getModificationTime, listDirectory)
import System.FSNotify (Event (..), EventIsDirectory (..), watchTree, withManager)
import System.FilePath (dropExtension, makeRelative, pathSeparator, takeExtension, (</>))
import Prelude hiding (lookup)

data GlueStore = GlueStore
    { lookup :: GlueLookup
    , runWatcher :: GluePublish
    }

makeGlueStore :: FilePath -> IO GlueStore
makeGlueStore folder = do
    root <- canonicalizePath folder
    index <- newIORef =<< buildIndex root

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

            void $ watchTree mgr root (const True) (writeChan inChan)
            forever $ threadDelay 1_000_000

        handle publish (Modified path time IsFile) = updateAndPublish publish path time
        handle publish (Added path time IsFile) = updateAndPublish publish path time
        handle _ (Removed path _ IsFile) = removeFromIndex path
        handle _ (Added _ _ IsDirectory) = rebuildIndex
        handle _ (Removed _ _ IsDirectory) = rebuildIndex
        handle _ _ = pure ()

        updateAndPublish publish path time = catch @SomeException
            do
                key <- keyForPath path
                case key of
                    Nothing -> pure ()
                    Just key' -> do
                        atomicModifyIORef' index (\current -> (M.insert key' path current, ()))
                        payload <- L.readFile path
                        let version = utcTimeToMillis time
                        let value = Revision{..}
                        publish key' value
            \err -> do
                print err
                pure ()

        removeFromIndex path = do
            key <- keyForPath path
            case key of
                Nothing -> pure ()
                Just key' -> atomicModifyIORef' index (\current -> (M.delete key' current, ()))

        rebuildIndex = buildIndex root >>= writeIORef index

        keyForPath path = pure $ glueKey (makeRelative root path)

    pure GlueStore{..}

utcTimeToMillis :: UTCTime -> Int
utcTimeToMillis utc = round $ utcTimeToPOSIXSeconds utc * 1000

replace :: (Eq a) => a -> a -> [a] -> [a]
replace old new = map (\x -> if x == old then new else x)

glueKey :: FilePath -> Maybe T.Text
glueKey path
    | takeExtension path == ".glue" =
        Just . T.pack $ replace pathSeparator '.' (dropExtension path)
    | otherwise = Nothing

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
            else do
                let relative = makeRelative root path
                pure $ maybe index (\key -> M.insert key path index) (glueKey relative)
