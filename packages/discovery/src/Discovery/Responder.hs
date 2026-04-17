module Discovery.Responder (
    startResponder,
    requestHost,
    requestPort,
) where

import Control.Exception qualified as E
import Control.Monad (forever, unless, void)
import Data.ByteString qualified as S
import Data.ByteString.Char8 qualified as C
import Data.List.NonEmpty qualified as NE
import Network.Socket
import Network.Socket.ByteString (recvFrom, sendTo)

-- Requests address (localhost UDP)
requestHost :: String
requestHost = "192.168.11.210"

requestPort :: String
requestPort = "5002"

-- Start the responder - listens for discovery requests and sends unicast responses
startResponder :: String -> IO ()
startResponder serviceName = do
    addr <- resolveAddr
    E.bracket (open addr) close loop
  where
    resolveAddr = do
        let hints =
                defaultHints
                    { addrFlags = [AI_PASSIVE]
                    , addrSocketType = Datagram
                    , addrFamily = AF_INET
                    }
        NE.head <$> getAddrInfo (Just hints) Nothing (Just requestPort)
    open addr = E.bracketOnError (openSocket addr) close $ \sock -> do
        setSocketOption sock ReuseAddr 1
        withFdSocket sock setCloseOnExecIfNeeded
        bind sock $ addrAddress addr
        return sock
    loop sock = forever $ do
        (msg, peer) <- recvFrom sock 1024
        unless (S.null msg) $ do
            putStr "Responder: received request from "
            putStr (show peer)
            putStr ": "
            C.putStrLn msg
            -- Send unicast response back to the requester
            let response = C.pack $ "ANNOUNCE:" ++ serviceName
            void $ sendTo sock response peer
            putStrLn $ "Responder: sent announcement to " ++ show peer
