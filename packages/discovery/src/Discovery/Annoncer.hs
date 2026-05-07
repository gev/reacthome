module Discovery.Annoncer (
    runAnnoncer,
) where

import Control.Concurrent
import Control.Exception
import Control.Monad
import Data.Foldable
import Data.List.NonEmpty qualified as NE
import Network.Info
import Network.Socket
import Network.Socket.ByteString

runAnnoncer :: HostName -> ServiceName -> IO ()
runAnnoncer group port = do
    group' <- resolve group
    forever
        do
            ifaces <- filter real <$> getNetworkInterfaces
            for_ ifaces \iface -> do
                host' <- resolve iface.name
                handle @SomeException print do
                    bracket (openSocket host') close \sock -> do
                        setSockOpt sock MulticastLoop False
                        putStrLn $ "sending hello to " <> iface.name
                        sendAllTo sock "hello" group'.addrAddress
            threadDelay 1_000_000
  where
    resolve addr =
        NE.head
            <$> getAddrInfo
                (Just defaultHints{addrFamily = AF_INET, addrSocketType = Datagram})
                (Just addr)
                (Just port)

    real NetworkInterface{..} = ipv4 /= IPv4 0 && mac /= MAC 0 0 0 0 0 0
