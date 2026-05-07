module Discovery.Utils where

import Control.Exception
import Data.List.NonEmpty qualified as NE
import Foreign
import Network.Info
import Network.Socket

resolve :: HostName -> ServiceName -> IO AddrInfo
resolve addr port =
    NE.head
        <$> getAddrInfo
            ( Just
                defaultHints
                    { addrFamily = AF_INET
                    , addrSocketType = Datagram
                    }
            )
            (Just addr)
            (Just port)

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

trySetSockOpt :: (Storable a) => Socket -> SocketOption -> a -> IO ()
trySetSockOpt sock opt val = handle @SomeException ignore do
    setSockOpt sock opt val
  where
    ignore = const $ pure ()
