import Control.Concurrent (forkIO, threadDelay)
import Control.Monad (forever, replicateM)
import Data.Foldable (traverse_)
import Data.UUID.V4 (nextRandom)
import Reacthome.Daemon.App (application)
import Reacthome.Relay.Stat (RelayHits (hits), RelayStat (..), makeRelayStat)
import Web.WebSockets.Client (runWebSocketClient)

concurrency :: Int
concurrency = 5

main :: IO ()
main = do
    stats <- replicateM concurrency makeRelayStat
    let
        port = 3003
        host = "127.0.0.1"

        run stat = forkIO do
            peer <- nextRandom
            let path = "/" <> show peer
            putStrLn $ "Connect to Reacthome Relay on " <> host <> ":" <> show port <> path
            runWebSocketClient host port path $ application peer stat

    let summarize x = sum <$> traverse (hits . x) stats
        rps x1 x0 = show x1 <> " | " <> show (x1 - x0) <> " rps"

    traverse_ run stats

    forever do
        tx0 <- summarize tx
        rx0 <- summarize rx
        threadDelay 1_000_000
        tx1 <- summarize tx
        rx1 <- summarize rx
        putStrLn $ "Tx: " <> rps tx1 tx0
        putStrLn $ "Rx: " <> rps rx1 rx0
