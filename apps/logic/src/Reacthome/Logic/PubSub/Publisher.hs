module Reacthome.Logic.PubSub.Publisher where

import Control.Concurrent.STM (atomically)
import Control.Monad (mfilter)
import Data.Foldable (traverse_)
import Data.Hashable (Hashable)
import ListT qualified as L
import Reacthome.Logic.PubSub.Versioned (Versioned (..))
import StmContainers.Multimap qualified as MM
import StmContainers.Set qualified as S

type PubSubGetter k t v = k -> IO (Maybe (Versioned t v))
type PubSubSender k t v = k -> Versioned t v -> IO ()

data Publisher s k t v = Publisher
    { subscribe :: s -> k -> v -> IO ()
    , unsubscribe :: s -> k -> IO ()
    , unsubscribeAll :: s -> IO ()
    , publish :: k -> Versioned t v -> IO ()
    }

makePublisher ::
    (Hashable s, Hashable k, Ord v) =>
    PubSubGetter k t v ->
    (s -> PubSubSender k t v) ->
    IO (Publisher s k t v)
makePublisher get send = do
    keySubscribes <- MM.newIO
    subscribeKeys <- MM.newIO
    let
        subscribe subscriber key version = do
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
                        (\s -> send s key value)
                        (S.listTNonAtomic subscribers)
                Nothing -> pure ()

    pure Publisher{..}
