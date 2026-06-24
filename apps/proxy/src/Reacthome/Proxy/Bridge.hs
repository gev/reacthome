module Reacthome.Proxy.Bridge where

import Control.Concurrent.Chan.Unagi.Bounded (Element (tryRead), newChan, tryReadChan, writeChan)
import Data.ByteString.Lazy (ByteString)
import Data.Text.Lazy.Encoding (encodeUtf8)
import Glue.Serialize (serializeAST)
import PubSub.Publisher (Publisher (..))
import PubSub.Revision (Revision (..))
import Reacthome.Proxy.Daemon.Actions (decodeAction)
import Reacthome.Proxy.Glue.PubSub.GlueOp (GlueOp (..))
import Reacthome.Proxy.Glue.PubSub.Publisher (GluePublisher)
import WebSockets.Connection (WebSocketSink, WebSocketSource)

data Bridge = Bridge
    { upstream :: Upstream
    , downstream :: Downstream
    }

makeBridge :: (?pubsub :: GluePublisher) => IO Bridge
makeBridge = do
    let upstream = makeUpstream
    downstream <- makeDownstream
    pure Bridge{..}

data Downstream = Downstream
    { send :: WebSocketSink
    , receive :: WebSocketSource
    }

makeDownstream :: IO Downstream
makeDownstream = do
    (inChan, outChan) <- newChan 10
    let send = writeChan inChan
    let receive =
            do
                (!element, !wait) <- tryReadChan outChan
                !message <- tryRead element
                pure (message, wait)
    pure Downstream{..}

newtype Upstream = Upstream
    { publish :: ByteString -> IO ()
    }

makeUpstream :: (?pubsub :: GluePublisher) => Upstream
makeUpstream = Upstream{..}
  where
    publish action =
        case decodeAction action of
            Just (id', value, version) -> do
                let key = ["proxy", id']
                let payload = Put . encodeUtf8 . serializeAST $ value
                let revision = Revision{..}
                ?pubsub.publish key revision
            Nothing -> pure ()
