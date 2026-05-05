module Discovery.Annoncer (
    runAnnoncer,
) where

import Control.Concurrent
import Control.Exception
import Control.Monad
import Data.List.NonEmpty qualified as NE
import Network.Socket
import Network.Socket.ByteString

runAnnoncer :: HostName -> ServiceName -> IO ()
runAnnoncer host port = do
    addr <- resolve
    bracket (socket AF_INET Datagram defaultProtocol) close \sock -> forever do
        sendAllTo sock "hello" addr.addrAddress
        threadDelay 1_000_000
  where
    resolve = do
        let hints = defaultHints{addrSocketType = Datagram, addrFamily = AF_INET}
        NE.head <$> getAddrInfo (Just hints) (Just host) (Just port)
