module Discovery.Broadcaster where

import Control.Exception
import Data.ByteString (ByteString)
import Data.Foldable
import Discovery.Utils
import Network.Socket
import Network.Socket.ByteString

broadcast :: AddrInfo -> ByteString -> IO ()
broadcast group message = do
    ifaces <- getInterfaces
    for_ ifaces \iface -> do
        host <- resolveHost iface
        handle @SomeException print do
            bracket (openSocket host) close \sock -> do
                setSockOpt sock MulticastLoop False
                sendAllTo sock message group.addrAddress
