module Discovery.Utils where

import Control.Concurrent
import Control.Exception
import Data.List.NonEmpty qualified as NE
import Foreign
import Network.Info
import Network.Socket

udp :: AddrInfo
udp =
    defaultHints
        { addrFamily = AF_INET
        , addrSocketType = Datagram
        }

resolve :: HostName -> PortNumber -> IO AddrInfo
resolve addr port =
    NE.head <$> getAddrInfo (Just udp) (Just addr) (Just $ show port)

resolveHost :: HostName -> IO AddrInfo
resolveHost addr =
    NE.head <$> getAddrInfo (Just udp) (Just addr) Nothing

getInterfaces :: IO [HostName]
getInterfaces = do
    ifaces <- getNetworkInterfaces
    pure $ show . ipv4 <$> filter real ifaces
  where
    real NetworkInterface{..} =
        ipv4 /= IPv4 0 && mac /= MAC 0 0 0 0 0 0

hostAddress :: SockAddr -> HostAddress
hostAddress (SockAddrInet _ addr) = addr
hostAddress _ = error "Unsupported socket address"

setPort :: SockAddr -> PortNumber -> SockAddr
setPort (SockAddrInet _ addr) port = SockAddrInet port addr
setPort (SockAddrInet6 _ flow addr scope) port = SockAddrInet6 port flow addr scope
setPort _ _ = error "Unsupported socket address"

trySetSockOpt :: (Storable a) => Socket -> SocketOption -> a -> IO ()
trySetSockOpt sock opt val = handle @SomeException ignore do
    setSockOpt sock opt val
  where
    ignore = const $ pure ()

delay :: Int -> IO ()
delay = threadDelay . seconds

seconds :: Int -> Int
seconds = (1_000_000 *)
