module Reacthome.Proxy.Glue.PubSub.Publisher where

import Data.ByteString.Builder qualified as B
import Data.ByteString.Lazy qualified as L
import Data.Text qualified as T
import Data.Text.Encoding (encodeUtf8)
import PubSub.Publisher (makePublisher)
import PubSub.Revision (Revision (..))
import Reacthome.Proxy.Bridge.Downstream (Downstream)
import Reacthome.Proxy.Glue.Dispatcher (dispatch)
import Reacthome.Proxy.Glue.PubSub.Types (GluePublisher)
import Reacthome.Proxy.Glue.Store (GlueStore)
import Reacthome.Proxy.Sink (SinkRegistry (..))

makeGluePublisher ::
    ( ?store :: GlueStore
    , ?sinks :: SinkRegistry
    , ?downstream :: Downstream
    ) =>
    IO GluePublisher
makeGluePublisher =
    makePublisher dispatch send
  where
    send subscriber key value = do
        maybeSink <- ?sinks.lookup subscriber
        case maybeSink of
            Just sink -> do
                let message =
                        B.toLazyByteString $
                            B.word8 1
                                <> B.string8 "(put \""
                                <> B.lazyByteString (enc key)
                                <> B.string8 "\" "
                                <> B.intDec value.version
                                <> B.string8 " "
                                <> B.lazyByteString value.payload
                                <> B.string8 ")"
                sink message
            Nothing -> print $ "Subscriber not found: " <> show subscriber

    enc = L.fromStrict . encodeUtf8 . T.intercalate "."
