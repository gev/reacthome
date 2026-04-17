import Control.Concurrent (forkIO, threadDelay)
import Control.Monad (forever, void)
import Discovery.Anoncer (startAnoncer)
import Discovery.Responder (startResponder)
import Discovery.Scanner (startScanner)

main :: IO ()
main = do
    putStrLn "Starting Discovery System..."

    -- Start responder (listens for discovery requests and responds with unicast)
    void $ forkIO $ do
        putStrLn "Starting Responder..."
        startResponder "TestService:192.168.1.100:8080"

    threadDelay 500_000 -- Small delay to ensure responder is ready

    -- Start anoncer (periodically announces to the announcement group)
    void $ forkIO $ do
        putStrLn "Starting Anoncer..."
        startAnoncer "TestService:192.168.1.100:8080"

    threadDelay 500_000 -- Small delay to ensure anoncer is running

    -- Start scanner (sends discovery requests and listens for announcements)
    putStrLn "Starting Scanner..."
    scanner
  where
    scanner = forever $ do
        startScanner
        threadDelay 3_000_000 -- Restart scanner every 30 seconds
