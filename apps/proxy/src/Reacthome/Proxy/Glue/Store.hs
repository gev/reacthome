module Reacthome.Proxy.Glue.Store where

import Control.Concurrent (threadDelay)
import Control.Exception (SomeException, catch)
import Control.Monad (forever, void, when)
import Data.ByteString.Lazy qualified as L
import Data.List (intercalate)
import Data.Text (Text)
import Data.Text qualified as T
import Data.Time.Clock (UTCTime)
import Data.Time.Clock.POSIX (utcTimeToPOSIXSeconds)
import PubSub.Publisher (PubSubGetter, PubSubSender)
import PubSub.Revision (Revision (..))
import System.Directory (canonicalizePath, getModificationTime)
import System.FSNotify (Event (..), EventIsDirectory (..), watchTree, withManager)
import System.FilePath (pathSeparator, splitDirectories)

data GlueStore = GlueStore
    { get :: PubSubGetter [Text] L.ByteString Int
    , runWatcher :: PubSubSender [Text] L.ByteString Int -> IO ()
    }

makeGlueStore :: FilePath -> GlueStore
makeGlueStore folder = GlueStore{..}
  where
    get parts = do
        let file = folder <> intercalate [pathSeparator] (T.unpack <$> parts) <> ".glue"
        catch @SomeException
            do
                payload <- L.readFile file
                version <- utcTimeToMillis <$> getModificationTime file
                pure $ Just Revision{..}
            \err -> do
                print err
                pure Nothing

    runWatcher publish = withManager \mgr -> do
        void $ watchTree mgr folder (const True) (handle publish)
        forever $ threadDelay 1_000_000

    handle publish (Modified path time IsFile) = do
        catch @SomeException
            do
                absolute <- canonicalizePath folder
                let file = drop (length absolute + 1) path
                let (key, ext) = splitAt (length file - 5) file
                when (ext == ".glue") do
                    payload <- L.readFile path
                    let parts = splitDirectories key
                    let version = utcTimeToMillis time
                    let value = Revision{..}
                    publish (T.pack <$> parts) value
            \err -> do
                print err
                pure ()
    handle _ _ = pure ()

utcTimeToMillis :: UTCTime -> Int
utcTimeToMillis utc = round $ utcTimeToPOSIXSeconds utc * 1000
