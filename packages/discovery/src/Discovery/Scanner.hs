module Discovery.Scanner (
    runScanner,
) where

import Control.Exception
import Control.Monad
import Network.Socket

import Control.Concurrent (threadDelay)
import Discovery.Utils
import Network.Socket.ByteString

runScanner :: HostName -> ServiceName -> IO ()
runScanner group port = do
    hostInfo <- resolve "0.0.0.0" port
    groupAddr <- hostAddress . addrAddress <$> resolve group port
    forever do
        handle @SomeException print $ do
            let multicast = MulticastGroup groupAddr Nothing
            bracket (openSocket hostInfo) close \sock -> do
                setSockOpt sock ReusePort True
                bind sock hostInfo.addrAddress
                setSockOpt sock AddMembership multicast
                forever do
                    (msg, addr) <- recvFrom sock 1024
                    print $ show addr <> ": " <> show msg
        threadDelay 1_000_000
