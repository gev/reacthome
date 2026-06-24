module Reacthome.Proxy.Glue.PubSub.Publisher where

import Data.ByteString.Builder qualified as B
import Data.ByteString.Lazy qualified as L
import Data.Text (Text)
import Data.Text qualified as T
import Data.Text.Encoding (encodeUtf8)
import Data.UUID (UUID)
import PubSub.Publisher (Publisher, makePublisher)
import PubSub.Revision (Revision (..))
import Reacthome.Proxy.Glue.PubSub.GlueOp (GlueOp (..))
import Reacthome.Proxy.Glue.Store (GlueStore (..))
import Reacthome.Proxy.Sink (SinkRegistry (..))

type GluePublisher = Publisher UUID [Text] L.ByteString GlueOp Int

makeGluePublisher ::
    ( ?store :: GlueStore
    , ?sinks :: SinkRegistry
    ) =>
    IO GluePublisher
makeGluePublisher =
    makePublisher ?store.get Put send
  where
    send subscriber key value = do
        maybeSink <- ?sinks.lookup subscriber
        case maybeSink of
            Just sink ->
                let (cmd, payload) = case value.payload of
                        Put p -> ("(put ", p)
                        Patch p -> ("(patch ", p)
                 in sink . B.toLazyByteString $
                        B.word8 1
                            <> B.string8 cmd
                            <> B.lazyByteString (enc key)
                            <> B.string8 " "
                            <> B.intDec value.version
                            <> B.string8 " "
                            <> B.lazyByteString payload
                            <> B.string8 ")"
            Nothing -> print $ "Sibscriber not found: " <> show subscriber

    enc = L.fromStrict . encodeUtf8 . T.intercalate "."
