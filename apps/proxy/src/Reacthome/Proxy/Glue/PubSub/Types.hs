module Reacthome.Proxy.Glue.PubSub.Types where

import Data.ByteString.Lazy qualified as L
import Data.Text (Text)
import Data.UUID (UUID)
import PubSub.Publisher (PubSubGetter, PubSubSender, Publisher)

type GluePubSubGetter = PubSubGetter [Text] L.ByteString Int
type GluePubSubSender = PubSubSender [Text] L.ByteString Int -> IO ()

type GluePublisher = Publisher UUID [Text] L.ByteString Int
