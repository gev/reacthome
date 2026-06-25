module Reacthome.Proxy.Bridge where

import Control.Concurrent.Chan.Unagi.Bounded (Element (tryRead), newChan, tryReadChan, writeChan)
import Data.ByteString.Lazy (ByteString)
import Data.Text.Lazy.Encoding (encodeUtf8)
import Glue.Serialize (serializeAST)
import PubSub.Publisher (Publisher (..))
import PubSub.Revision (Revision (..))
import Reacthome.Proxy.Daemon.Actions (decodeAction)
import Reacthome.Proxy.Glue.PubSub.GlueOp (GlueOp (..), GluePublisher)
import WebSockets.Connection (WebSocketSink, WebSocketSource)

data Downstream = Downstream
    { send :: WebSocketSink
    , receive :: WebSocketSource
    }

makeDownstream :: IO Downstream
makeDownstream = do
    (inChan, outChan) <- newChan 10
    let send message = do
            print message
            writeChan inChan message
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
            Just (key, value, version) -> do
                let payload = Patch . encodeUtf8 . serializeAST $ value
                let revision = Revision{..}
                print revision
                ?pubsub.publish key revision
            Nothing -> pure ()
