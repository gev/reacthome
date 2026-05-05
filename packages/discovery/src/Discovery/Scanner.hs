module Discovery.Scanner (
    runScanner,
) where

import Control.Concurrent
import Control.Exception
import Control.Monad
import Data.List.NonEmpty qualified as NE
import Network.Socket
import Network.Socket.ByteString

runScanner :: HostName -> ServiceName -> IO ()
runScanner host port = do
    addr <- resolve
    bracket (openSocket addr) close \sock -> do
        bind sock addr.addrAddress
        forever do
            msg <- recv sock 1024
            print msg
  where
    resolve = do
        let hints = defaultHints{addrSocketType = Datagram, addrFamily = AF_INET}
        NE.head <$> getAddrInfo (Just hints) (Just host) (Just port)
