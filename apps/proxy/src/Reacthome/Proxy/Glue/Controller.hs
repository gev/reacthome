module Reacthome.Proxy.Glue.Controller where

import Data.ByteString.Lazy as B (ByteString, uncons)
import Data.Text.Lazy (toStrict)
import Data.Text.Lazy.Encoding (decodeUtf8')
import Data.UUID (UUID)
import Data.Word (Word8)
import Reacthome.Proxy.Assets (Assets)
import Reacthome.Proxy.Glue.Evaluator (run)
import Reacthome.Proxy.Glue.PubSub.Publisher (GluePublisher)
import Reacthome.Proxy.Sink (Sink)

pattern HeartBeat :: Word8
pattern HeartBeat = 0
pattern Glue :: Word8
pattern Glue = 1
pattern File :: Word8
pattern File = 2

controller ::
    ( ?session :: UUID
    , ?pubsub :: GluePublisher
    , ?assets :: Assets
    , ?sink :: Sink
    ) =>
    ByteString -> IO ()
controller message =
    case uncons message of
        Nothing -> putStrLn "Empty message"
        Just (header, body) -> case header of
            HeartBeat -> heartBeat
            Glue -> runGlue body
            File -> acceptFile body
            _ -> putStrLn "Unknown header"

heartBeat :: IO ()
heartBeat = pure ()

runGlue ::
    ( ?session :: UUID
    , ?pubsub :: GluePublisher
    , ?assets :: Assets
    , ?sink :: Sink
    ) =>
    ByteString -> IO ()
runGlue message = do
    print message
    case decodeUtf8' message of
        Left err -> print err
        Right expression -> do
            run (toStrict expression) >>= \case
                Left err -> print err
                _ -> pure ()

acceptFile :: ByteString -> IO ()
acceptFile _ = pure ()
