module Reacthome.Logic.Glue.Publisher where

import Data.ByteString.Builder qualified as B
import Data.ByteString.Lazy qualified as L
import Data.Text (Text)
import Data.Text qualified as T
import Data.Text.Encoding (encodeUtf8)
import Data.UUID (UUID)
import Reacthome.Logic.Glue.Sink (SinkRegistry (..))
import Reacthome.Logic.Glue.Store (GlueStore (..))
import PubSub.Publisher (Publisher, makePublisher)
import PubSub.Revision (Revision (..))

type GluePublisher = Publisher UUID [Text] L.ByteString Int

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
            Just sink ->
                sink . B.toLazyByteString $
                    B.word8 1
                        <> B.string8 "(put "
                        <> B.lazyByteString (enc key)
                        <> B.string8 " "
                        <> B.intDec value.version
                        <> B.string8 " "
                        <> B.lazyByteString value.payload
                        <> B.string8 ")"
            Nothing -> print $ "Sibscriber not found: " <> show subscriber

    enc = L.fromStrict . encodeUtf8 . T.intercalate "."
