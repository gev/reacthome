module Discovery.Annoncer where

import Control.Concurrent
import Control.Exception
import Control.Monad
import Data.Foldable
import Discovery.Utils
import Network.Socket
import Network.Socket.ByteString

runAnnoncer :: HostName -> ServiceName -> IO ()
runAnnoncer group port = do
    group' <- resolve group port
    forever
        do
            ifaces <- getInterfaces
            for_ ifaces \iface -> do
                host' <- resolve iface port
                handle @SomeException print do
                    bracket (openSocket host') close \sock -> do
                        setSockOpt sock MulticastLoop False
                        putStrLn $ "sending hello to " <> iface
                        sendAllTo sock "hello" group'.addrAddress
            threadDelay 1_000_000
