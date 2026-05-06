module Discovery.Annoncer (
    runAnnoncer,
) where

import Control.Concurrent
import Control.Exception
import Control.Monad
import Data.List.NonEmpty qualified as NE
import Network.Socket
import Network.Socket.ByteString

runAnnoncer :: HostName -> HostName -> ServiceName -> IO ()
runAnnoncer host group port = do
    group' <- resolve group
    bracket (socket AF_INET Datagram defaultProtocol) close \sock -> do
        forever do
            sendAllTo sock "hello" group'.addrAddress
            threadDelay 1_000_000
  where
    resolve addr = NE.head <$> getAddrInfo Nothing (Just addr) (Just port)
