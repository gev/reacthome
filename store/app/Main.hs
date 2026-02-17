main :: IO ()
main = do
    let port = 3004
        host = "0.0.0.0"
    putStrLn $ "Start Reacthome Domain on " <> host <> ":" <> show port
