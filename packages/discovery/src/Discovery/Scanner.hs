module Discovery.Scanner (
    runScanner,
) where

import Control.Exception
import Control.Monad
import Data.List.NonEmpty qualified as NE
import Network.Socket
import Network.Socket.ByteString

runScanner :: HostName -> HostName -> ServiceName -> IO ()
runScanner host group port = do
    host' <- resolve host
    group' <- resolve group
    bracket (openSocket host') close \sock -> do
        bind sock host'.addrAddress
        setSocketOption sock AddMembership group'.addrAddress
        forever do
            msg <- recv sock 100
            print msg
  where
    resolve addr = do
        let hints = defaultHints{addrSocketType = Datagram, addrFamily = AF_INET}
        NE.head <$> getAddrInfo (Just hints) (Just addr) (Just port)
