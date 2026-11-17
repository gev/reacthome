module Reacthome.Proxy.Glue.Controller where

import Data.ByteString.Lazy as B (ByteString, uncons)
import Data.Text.Lazy (toStrict)
import Data.Text.Lazy.Encoding (decodeUtf8')
import Data.UUID (UUID)
import Data.Word (Word8)
import Reacthome.Proxy.Assets (Assets)
import Reacthome.Proxy.Bridge.Downstream (Downstream)
import Reacthome.Proxy.Glue.Env.Vision (visionEnv)
import Reacthome.Proxy.Glue.Evaluator (evaluate)
import Reacthome.Proxy.Glue.PubSub.Types (GluePublisher)
import Reacthome.Proxy.Sink (Sink)

pattern HeartBeat :: Word8
pattern HeartBeat = 0
pattern Glue :: Word8
pattern Glue = 1
pattern File :: Word8
pattern File = 2

newtype Controller = Controller
    { run :: UUID -> Sink -> ByteString -> IO ()
    }

makeController ::
    ( ?pubsub :: GluePublisher
    , ?assets :: Assets
    , ?downstream :: Downstream
    ) =>
    IO Controller
makeController = do
    let
        run session sink message = do
            let
                ?session = session
                ?sink = sink
            case uncons message of
                Nothing -> putStrLn "Empty message"
                Just (header, body) -> case header of
                    HeartBeat -> heartBeat
                    Glue -> runGlue body
                    File -> acceptFile body
                    _ -> putStrLn "Unknown header"
    pure Controller{..}

heartBeat :: IO ()
heartBeat = pure ()

runGlue ::
    ( ?session :: UUID
    , ?pubsub :: GluePublisher
    , ?assets :: Assets
    , ?sink :: Sink
    , ?downstream :: Downstream
    ) =>
    ByteString -> IO ()
runGlue message = do
    case decodeUtf8' message of
        Left err -> print err
        Right expression -> do
            evaluate (toStrict expression) visionEnv >>= \case
                Left err -> print err
                _ -> pure ()

acceptFile :: ByteString -> IO ()
acceptFile _ = pure ()
