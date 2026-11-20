module PubSub.Publisher where

import Control.Concurrent.STM (atomically)
import Control.Monad (mfilter, unless)
import Data.Foldable (traverse_)
import Data.Hashable (Hashable)
import ListT qualified as L
import PubSub.Revision (Revision (..))
import StmContainers.Multimap qualified as MM
import StmContainers.Set qualified as S

type Lookup k t v = k -> IO (Maybe (Revision t v))
type Publish k t v = k -> Revision t v -> IO ()
type TryPublish k t v = k -> Revision t v -> IO Bool

data Publisher s k t v = Publisher
    { subscribe :: s -> k -> v -> IO ()
    , unsubscribe :: s -> k -> IO ()
    , unsubscribeAll :: s -> IO ()
    , publish :: Publish k t v
    }

makePublisher ::
    (Hashable s, Hashable k, Ord v, Show s) =>
    Lookup k t v ->
    (s -> TryPublish k t v) ->
    IO (Publisher s k t v)
makePublisher get send = do
    keySubscribes <- MM.newIO
    subscribeKeys <- MM.newIO
    let
        subscribe subscriber key version =
            do
                atomically do
                    MM.insert subscriber key keySubscribes
                    MM.insert key subscriber subscribeKeys
                get key
                    >>= traverse_ (send subscriber key) . mfilter
                        \v -> v.version > version
        unsubscribe subscriber key = atomically do
            MM.delete subscriber key keySubscribes
            MM.delete key subscriber subscribeKeys

        unsubscribeAll subscriber = atomically do
            maybeKeys <- MM.lookupByKey subscriber subscribeKeys
            case maybeKeys of
                Just keys ->
                    L.traverse_
                        (\k -> MM.delete subscriber k keySubscribes)
                        (S.listT keys)
                Nothing -> pure ()
            MM.deleteByKey subscriber subscribeKeys

        publish key value = do
            maybesubscribers <- atomically do
                MM.lookupByKey key keySubscribes
            case maybesubscribers of
                Just subscribers ->
                    L.traverse_
                        ( \s -> do
                            published <- send s key value
                            unless published do
                                unsubscribeAll s
                                print $ "Subscriber not found: " <> show s
                        )
                        (S.listTNonAtomic subscribers)
                Nothing -> pure ()

    pure Publisher{..}
