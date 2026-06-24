module Reacthome.Proxy.Bridge where

import Control.Concurrent.Chan.Unagi.Bounded (Element (tryRead), newChan, tryReadChan, writeChan)
import Data.ByteString.Lazy (ByteString)
import Reacthome.Proxy.Daemon.Actions (decodeAction)
import WebSockets.Connection (WebSocketSink, WebSocketSource)

data Bridge = Bridge
    { upstream :: Upstream
    , downstream :: Downstream
    }

makeBridge :: IO Bridge
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

makeUpstream :: Upstream
makeUpstream = Upstream $ print . decodeAction
