module Reacthome.Proxy.Glue.PubSub.Types where

import Data.ByteString.Lazy qualified as L
import Data.Text (Text)
import Data.UUID (UUID)
import PubSub.Publisher (Lookup, Publish, Publisher)

type GlueLookup = Lookup [Text] L.ByteString Int
type GluePublish = Publish [Text] L.ByteString Int -> IO ()

type GluePublisher = Publisher UUID [Text] L.ByteString Int
