module Discovery.Anoncer (
    startAnoncer,
    announcementHost,
    announcementPort,
) where

import Control.Concurrent (threadDelay)
import Control.Exception qualified as E
import Control.Monad (forever, void)
import Data.ByteString.Char8 qualified as C
import Data.List.NonEmpty qualified as NE
import Network.Socket
import Network.Socket.ByteString (sendTo)

-- Announcements address (localhost UDP)
announcementHost :: String
announcementHost = "192.168.11.210"

announcementPort :: String
announcementPort = "5001"

-- Start the announcer - periodically sends announcements to the announcement port
startAnoncer :: String -> IO ()
startAnoncer serviceName = do
    addr <- resolveAddr
    E.bracket (openSocket addr) close $ \sock -> do
        forever $ do
            let announcement = C.pack $ "ANNOUNCE:" ++ serviceName
            void $ sendTo sock announcement (addrAddress addr)
            putStrLn $ "Anoncer: sent announcement for " ++ serviceName
            threadDelay 5_000_000 -- Send announcement every 5 seconds
  where
    resolveAddr = do
        let hints = defaultHints{addrSocketType = Datagram, addrFamily = AF_INET}
        NE.head <$> getAddrInfo (Just hints) (Just announcementHost) (Just announcementPort)
