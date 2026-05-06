import Control.Concurrent (threadDelay)
import Control.Concurrent.Async
import Control.Monad
import Network.Multicast
import Network.Socket
import Network.Socket.ByteString (recv, sendTo)

main :: IO ()
main = do
    void $ concurrently
        -- do runAnnoncer "192.168.11.210" "2026"
        -- do runScanner "192.168.11.210" "239.0.0.1" "2026"
        do
            withSocketsDo $ do
                (sock, addr) <- multicastSender "224.0.0.99" 9999
                let loop = do
                        let msg = "Hello, multicast!"
                        void $ sendTo sock msg addr
                        print $ "Send: " <> msg
                        threadDelay 1_000_000
                        loop
                loop
        do
            withSocketsDo $ do
                sock <- multicastReceiver "224.0.0.99" 9999
                let loop = do
                        msg <- recv sock 1024
                        print $ "Recv: " <> msg
                        loop
                loop
