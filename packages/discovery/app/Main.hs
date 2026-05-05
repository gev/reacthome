import Control.Concurrent.Async
import Control.Monad
import Discovery.Annoncer
import Discovery.Scanner

main :: IO ()
main = do
    void $ concurrently
        do runAnnoncer "localhost" "2026"
        do runScanner "localhost" "2026"
