module Discovery.Monitor where

import Control.Exception
import Control.Monad
import Data.ByteString (ByteString)
import Discovery.Utils
import Network.Socket
import Network.Socket.ByteString

type OnMessage = Socket -> ByteString -> SockAddr -> IO ()

monitor :: HostName -> PortNumber -> OnMessage -> IO ()
monitor group port onMessage = do
    hostInfo <- resolve "0.0.0.0" port
    groupAddr <- resolveHost group
    handle @SomeException print $ do
        let multicast = MulticastGroup (hostAddress groupAddr.addrAddress) Nothing
        bracket (openSocket hostInfo) close \sock -> do
            trySetSockOpt sock ReusePort True
            trySetSockOpt sock ReuseAddr True
            bind sock hostInfo.addrAddress
            setSockOpt sock AddMembership multicast
            forever do
                (msg, addr) <- recvFrom sock 1024
                onMessage sock msg addr
