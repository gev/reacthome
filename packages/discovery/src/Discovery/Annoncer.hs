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
    host' <- resolve host
    bracket (socket AF_INET Datagram defaultProtocol) close \sock -> forever do
        sendAllTo sock "hello" host'.addrAddress
        threadDelay 1_000_000
  where
    resolve addr = do
        let hints = defaultHints{addrSocketType = Datagram, addrFamily = AF_INET}
        NE.head <$> getAddrInfo (Just hints) (Just addr) (Just port)
