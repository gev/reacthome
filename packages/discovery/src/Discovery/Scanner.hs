module Discovery.Scanner (
    startScanner,
    announcementHost,
    announcementPort,
    requestHost,
    requestPort,
) where

import Control.Concurrent (forkIO, threadDelay)
import Control.Exception qualified as E
import Control.Monad (forever, unless, void)
import Data.ByteString qualified as S
import Data.ByteString.Char8 qualified as C
import Data.List.NonEmpty qualified as NE
import Network.Socket
import Network.Socket.ByteString (recvFrom, sendTo)

-- Announcements address (localhost UDP)
announcementHost :: String
announcementHost = "192.168.11.210"

announcementPort :: String
announcementPort = "5001"

-- Requests address (localhost UDP)
requestHost :: String
requestHost = "192.168.11.210"

requestPort :: String
requestPort = "5002"

-- Start the scanner - sends discovery requests and listens for announcements
startScanner :: IO ()
startScanner = do
    -- Fork the announcement listener
    void $ forkIO listenForAnnouncements
    -- Send discovery request at startup
    sendDiscoveryRequest
    -- Keep the scanner running
    forever $ threadDelay 1_000_000

-- Listen for announcements on the announcement port
listenForAnnouncements :: IO ()
listenForAnnouncements = do
    addr <- resolveAddrPassive announcementPort
    E.bracket (open addr) close loop
  where
    open addr = E.bracketOnError (openSocket addr) close $ \sock -> do
        setSocketOption sock ReuseAddr 1
        withFdSocket sock setCloseOnExecIfNeeded
        bind sock $ addrAddress addr
        return sock
    loop sock = forever $ do
        (msg, peer) <- recvFrom sock 1024
        unless (S.null msg) $ do
            putStr "Scanner received announcement from "
            putStr (show peer)
            putStr ": "
            C.putStrLn msg

-- Send a discovery request to the requests port
sendDiscoveryRequest :: IO ()
sendDiscoveryRequest = do
    addr <- resolveAddr requestHost requestPort
    E.bracket (openSocket addr) close $ \sock -> do
        let request = "DISCOVERY_REQUEST"
        void $ sendTo sock (C.pack request) (addrAddress addr)
        putStrLn "Scanner: sent discovery request"

-- Helper function to resolve addresses for sending
resolveAddr :: String -> String -> IO AddrInfo
resolveAddr host port = do
    let hints = defaultHints{addrSocketType = Datagram, addrFamily = AF_INET}
    NE.head <$> getAddrInfo (Just hints) (Just host) (Just port)

-- Helper function to resolve addresses for listening (passive)
resolveAddrPassive :: String -> IO AddrInfo
resolveAddrPassive port = do
    let hints =
            defaultHints
                { addrFlags = [AI_PASSIVE]
                , addrSocketType = Datagram
                , addrFamily = AF_INET
                }
    NE.head <$> getAddrInfo (Just hints) Nothing (Just port)
