module Reacthome.Proxy.Sink.SinkRegistry where

import Control.Monad (unless)
import Data.Foldable (for_)
import Data.Set qualified as Set
import Data.UUID (UUID)
import Reacthome.Proxy.Sink (Sink (..))
import Reacthome.Proxy.Sink.DirectSinkRegistry (DirectSinkRegistry (..), makeDirectSinkRegistry)
import Reacthome.Proxy.Sink.RelaySinkRegistry (RelaySinkRegistry (..), makeRelaySinkRegistry)
import Reacthome.Relay (LazyRaw)
import Prelude hiding (lookup)

data SinkRegistry = SinkRegistry
    { directSinks :: DirectSinkRegistry
    , relaySinks :: RelaySinkRegistry
    , send :: UUID -> LazyRaw -> IO Bool
    , broadcast :: LazyRaw -> IO ()
    }

makeSinkRegistry :: IO SinkRegistry
makeSinkRegistry = do
    directSinks <- makeDirectSinkRegistry
    relaySinks <- makeRelaySinkRegistry

    let
        send uid message =
            directSinks.lookup uid >>= \case
                Just sink -> do
                    sink.send message
                    pure True
                Nothing ->
                    relaySinks.lookup uid >>= \case
                        Just sink -> do
                            sink.send message
                            pure True
                        Nothing -> do
                            print $ "Sink not found: " <> show uid
                            pure False

        broadcast message = do
            (directs, relays) <-
                (,) <$> directSinks.all <*> relaySinks.all

            let done = Set.fromList $ map fst directs

            for_
                directs
                \(_, sink) -> sink.send message
            for_
                relays
                \(uid, sink) ->
                    unless (Set.member uid done) $
                        sink.send message

    pure
        SinkRegistry{..}
