import Control.Concurrent (forkIO)
import Control.Monad
import Discovery.Annoncer
import Discovery.Scanner

main :: IO ()
main = do
    void $ forkIO do runAnnoncer "239.0.0.1" "2026"
    do runScanner "239.0.0.1" "2026"
