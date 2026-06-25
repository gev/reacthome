module Reacthome.Proxy.Glue.PubSub.GlueOp where

import Data.ByteString.Lazy qualified as L
import Data.Text (Text)
import Data.UUID (UUID)
import PubSub.Publisher (PubSubGetter, PubSubSender, Publisher)

data GlueOp
    = Put L.ByteString
    | Patch L.ByteString
    deriving (Show)

type GluePubSubGetter = PubSubGetter [Text] L.ByteString Int
type GluePubSubSender = PubSubSender [Text] GlueOp Int -> IO ()

type GluePublisher = Publisher UUID [Text] L.ByteString GlueOp Int
