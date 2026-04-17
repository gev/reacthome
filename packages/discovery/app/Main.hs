import Control.Concurrent (forkFinally, forkIO, threadDelay)
import Control.Exception qualified as E
import Control.Monad (forever, unless, void)
import Data.ByteString qualified as S
import Data.ByteString.Char8 qualified as C
import Data.List.NonEmpty qualified as NE
import Network.Socket
import Network.Socket.ByteString (recv, sendAll)

main :: IO ()
main = do
    void $ forkIO do
        runTCPServer Nothing "3000" talk

    threadDelay 1_000_000

    runTCPClient "127.0.0.1" "3000" $ \s -> forever do
        sendAll s "Hello, world!"
        msg <- recv s 1024
        putStr "Received: "
        C.putStrLn msg
        threadDelay 1_000_000
  where
    talk s = forever do
        msg <- recv s 1024
        unless (S.null msg) $ do
            sendAll s msg

-- from the "network-run" package.
runTCPServer :: Maybe HostName -> ServiceName -> (Socket -> IO a) -> IO a
runTCPServer mhost port server = do
    addr <- resolve
    E.bracket (open addr) close loop
  where
    resolve = do
        let hints =
                defaultHints
                    { addrFlags = [AI_PASSIVE]
                    , addrSocketType = Stream
                    }
        NE.head <$> getAddrInfo (Just hints) mhost (Just port)
    open addr = E.bracketOnError (openSocket addr) close $ \sock -> do
        setSocketOption sock ReuseAddr 1
        withFdSocket sock setCloseOnExecIfNeeded
        bind sock $ addrAddress addr
        listen sock 1024
        return sock
    loop sock = forever $
        E.bracketOnError (accept sock) (close . fst) $
            \(conn, _peer) ->
                void $
                    -- 'forkFinally' alone is unlikely to fail thus leaking @conn@,
                    -- but 'E.bracketOnError' above will be necessary if some
                    -- non-atomic setups (e.g. spawning a subprocess to handle
                    -- @conn@) before proper cleanup of @conn@ is your case
                    forkFinally (server conn) (const $ gracefulClose conn 5000)

-- from the "network-run" package.
runTCPClient :: HostName -> ServiceName -> (Socket -> IO a) -> IO a
runTCPClient host port client = do
    addr <- resolve
    E.bracket (open addr) close client
  where
    resolve = do
        let hints = defaultHints{addrSocketType = Stream}
        NE.head <$> getAddrInfo (Just hints) (Just host) (Just port)
    open addr = E.bracketOnError (openSocket addr) close $ \sock -> do
        connect sock $ addrAddress addr
        return sock
