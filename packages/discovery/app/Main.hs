import Control.Concurrent (forkIO, threadDelay)
import Control.Exception qualified as E
import Control.Monad (forever, unless, void)
import Data.ByteString qualified as S
import Data.ByteString.Char8 qualified as C
import Data.List.NonEmpty qualified as NE
import Network.Socket
import Network.Socket.ByteString (recvFrom, sendTo)

main :: IO ()
main = do
    void $ forkIO do
        runUDPServer Nothing "3000"

    threadDelay 1_000_000

    runUDPClient "127.0.0.1" "3000"

-- UDP Server: listens for datagrams and echoes them back
runUDPServer :: Maybe HostName -> ServiceName -> IO ()
runUDPServer mhost port = do
    addr <- resolve
    E.bracket (open addr) close loop
  where
    resolve = do
        let hints =
                defaultHints
                    { addrFlags = [AI_PASSIVE]
                    , addrSocketType = Datagram
                    }
        NE.head <$> getAddrInfo (Just hints) mhost (Just port)
    open addr = E.bracketOnError (openSocket addr) close $ \sock -> do
        setSocketOption sock ReuseAddr 1
        withFdSocket sock setCloseOnExecIfNeeded
        bind sock $ addrAddress addr
        return sock
    loop sock = forever $ do
        (msg, peer) <- recvFrom sock 1024
        unless (S.null msg) $ do
            void $ sendTo sock msg peer

-- UDP Client: sends messages and receives responses
runUDPClient :: HostName -> ServiceName -> IO ()
runUDPClient host port = do
    serverAddr <- resolve
    E.bracket (openSocket serverAddr) close (client serverAddr)
  where
    resolve = do
        let hints = defaultHints{addrSocketType = Datagram}
        NE.head <$> getAddrInfo (Just hints) (Just host) (Just port)
    client serverAddr sock = forever $ do
        void $ sendTo sock "Hello, world!" (addrAddress serverAddr)
        (msg, _peer) <- recvFrom sock 1024
        putStr "Received: "
        C.putStrLn msg
        threadDelay 1_000_000
