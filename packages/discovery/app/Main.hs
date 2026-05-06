import Control.Concurrent.Async
import Control.Monad
import Discovery.Annoncer
import Discovery.Scanner

main :: IO ()
main = void $ concurrently
    do runAnnoncer "192.168.11.210" "239.0.0.1" "2026"
    do runScanner "0.0.0.0" "239.0.0.1" "2026"
