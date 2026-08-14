module Reacthome.Proxy.Bridge.Downstream where

import Control.Concurrent.Chan.Unagi.Bounded (Element (tryRead), newChan, tryReadChan, writeChan)
import Data.Aeson qualified as A
import WebSockets.Connection (WebSocketSource)

data Downstream = Downstream
    { send :: A.Object -> IO ()
    , receive :: WebSocketSource
    }

makeDownstream :: IO Downstream
makeDownstream = do
    (inChan, outChan) <- newChan 10_000
    let send message = do
            print message
            writeChan inChan $ A.encode message
    let receive =
            do
                (!element, !wait) <- tryReadChan outChan
                !message <- tryRead element
                pure (message, wait)
    pure Downstream{..}
