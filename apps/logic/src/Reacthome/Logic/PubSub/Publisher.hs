module Reacthome.Logic.PubSub.Publisher where

import Control.Concurrent.STM (atomically)
import Data.Foldable (traverse_)
import Data.Hashable (Hashable)
import ListT qualified as L
import StmContainers.Multimap qualified as MM
import StmContainers.Set qualified as S

type PubSubGetter k v = k -> IO (Maybe v)
type PubSubSender s k v = s -> k -> v -> IO ()

data Publisher s k v = Publisher
    { subscribe :: s -> k -> IO ()
    , unsubscribe :: s -> k -> IO ()
    , unsubscribeAll :: s -> IO ()
    , publish :: k -> v -> IO ()
    }

makePublisher ::
    (Hashable s, Hashable k) =>
    PubSubGetter k v ->
    PubSubSender s k v ->
    IO (Publisher s k v)
makePublisher get send = do
    keySubscribes <- MM.newIO
    subscribeKeys <- MM.newIO
    let
        subscribe subscriber key = do
            atomically do
                MM.insert subscriber key keySubscribes
                MM.insert key subscriber subscribeKeys
            traverse_ (send subscriber key) =<< get key

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
                        (\s -> send s key value)
                        (S.listTNonAtomic subscribers)
                Nothing -> pure ()

    pure Publisher{..}
