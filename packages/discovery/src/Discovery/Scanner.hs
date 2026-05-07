module Discovery.Scanner (
    runScanner,
) where

import Control.Exception
import Control.Monad
import Data.List.NonEmpty qualified as NE
import Network.Socket

import Control.Concurrent (threadDelay)
import Network.Socket.ByteString

runScanner :: HostName -> ServiceName -> IO ()
runScanner group port = do
    host' <- resolve "0.0.0.0"
    group' <- resolve group
    forever do
        handle @SomeException print $ do
            let multicast = MulticastGroup (hostAddress group'.addrAddress) Nothing
            bracket (openSocket host') close \sock -> do
                setSockOpt sock ReuseAddr True
                setSockOpt sock ReusePort True
                bind sock host'.addrAddress
                setSockOpt sock AddMembership multicast
                forever do
                    (msg, addr) <- recvFrom sock 1024
                    print $ show addr <> ": " <> show msg

        threadDelay 1_000_000
  where
    resolve addr =
        NE.head
            <$> getAddrInfo
                (Just defaultHints{addrFamily = AF_INET, addrSocketType = Datagram})
                (Just addr)
                (Just port)

hostAddress :: SockAddr -> HostAddress
hostAddress (SockAddrInet _ addr) = addr
hostAddress _ = error "Unsupported socket address"
