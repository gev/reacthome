module Discovery.Scanner (
    runScanner,
) where

import Control.Exception
import Control.Monad
import Data.List.NonEmpty qualified as NE
import Network.Multicast (addMembership)
import Network.Socket
import Network.Socket.ByteString

runScanner :: HostName -> HostName -> ServiceName -> IO ()
runScanner host group port = do
    host' <- resolve host
    bracket (socket AF_INET Datagram defaultProtocol) close \sock -> do
        bind sock host'.addrAddress
        addMembership sock group Nothing
        forever do
            msg <- recv sock 1024
            print msg
  where
    resolve addr = NE.head <$> getAddrInfo Nothing (Just addr) (Just port)
