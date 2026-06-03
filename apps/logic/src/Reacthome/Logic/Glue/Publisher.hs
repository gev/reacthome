module Reacthome.Logic.Glue.Publisher where

import Data.ByteString.Lazy qualified as L
import Data.Text (Text)
import Data.Text.Encoding (encodeUtf8)
import Data.UUID (UUID)
import Reacthome.Logic.Glue.Sink (SinkRegistry (..))
import Reacthome.Logic.Glue.Store (GlueStore (..))
import Reacthome.Logic.PubSub.Publisher (Publisher, makePublisher)

type GluePublisher = Publisher UUID Text L.ByteString

makeGluePublisher ::
    ( ?store :: GlueStore
    , ?sinks :: SinkRegistry
    ) =>
    IO GluePublisher
makeGluePublisher =
    makePublisher ?store.get send
  where
    send subscriber key value = do
        maybeSink <- ?sinks.lookup subscriber
        case maybeSink of
            Just sink -> sink $ L.cons' 1 "(put '" <> enc key <> " " <> value <> ")"
            Nothing -> print $ "Sibscriber not found: " <> show subscriber

    enc = L.fromStrict . encodeUtf8
