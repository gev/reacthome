import Control.Concurrent (forkIO, threadDelay)
import Control.Exception qualified as E
import Control.Monad (forever, unless, void)
import Data.ByteString qualified as S
import Data.ByteString.Char8 qualified as C
import Data.List.NonEmpty qualified as NE
import Network.Socket
import Network.Socket.ByteString (recvFrom, sendTo)

-- Discovery server and client configuration
discoveryHost :: HostName
discoveryHost = "127.0.0.1"

discoveryPort :: ServiceName
discoveryPort = "3000"

main :: IO ()
main = do
    void $ forkIO do
        runDiscoveryServer discoveryPort

    threadDelay 1_000_000

    runDiscoveryClient discoveryHost discoveryPort

-- Discovery Server: listens for discovery messages on localhost
runDiscoveryServer :: ServiceName -> IO ()
runDiscoveryServer port = do
    addr <- resolve
    E.bracket (open addr) close loop
  where
    resolve = do
        let hints =
                defaultHints
                    { addrFlags = [AI_PASSIVE]
                    , addrSocketType = Datagram
                    , addrFamily = AF_INET
                    }
        NE.head <$> getAddrInfo (Just hints) Nothing (Just port)
    open addr = E.bracketOnError (openSocket addr) close $ \sock -> do
        setSocketOption sock ReuseAddr 1
        withFdSocket sock setCloseOnExecIfNeeded
        bind sock $ addrAddress addr
        return sock
    loop sock = forever $ do
        (msg, peer) <- recvFrom sock 1024
        unless (S.null msg) $ do
            putStr "Server received from "
            putStr (show peer)
            putStr ": "
            C.putStrLn msg
            -- Echo the message back to the client
            void $ sendTo sock msg peer

-- Discovery Client: sends discovery messages to localhost
runDiscoveryClient :: HostName -> ServiceName -> IO ()
runDiscoveryClient host port = do
    serverAddr <- resolve
    E.bracket (openSocket serverAddr) close $ \sock -> do
        forever $ do
            void $ sendTo sock "DISCOVERY_REQUEST" (addrAddress serverAddr)
            putStrLn "Client sent: DISCOVERY_REQUEST"
            (msg, _peer) <- recvFrom sock 1024
            putStr "Client received: "
            C.putStrLn msg
            threadDelay 1_000_000
  where
    resolve = do
        let hints = defaultHints{addrSocketType = Datagram, addrFamily = AF_INET}
        NE.head <$> getAddrInfo (Just hints) (Just host) (Just port)
