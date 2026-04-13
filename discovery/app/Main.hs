main :: IO ()
main = do
    let port = 3012 :: Int
        group = "0.0.0.0"
    putStrLn $ "Start Discovery Service" <> group <> ":" <> show port
