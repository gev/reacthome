module Reacthome.Logic.Glue.Lib.Vision.Get where

import Data.ByteString qualified as BS
import Data.Text (Text, unpack)
import Data.Text.Encoding (encodeUtf8)
import Glue.Eval (Eval, liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Reacthome.Logic.Glue.Sink (Sink)

get :: (?sink :: Sink) => IR Eval
get = NativeFunc getImpl

getImpl :: (?sink :: Sink) => IR Eval -> Eval (IR Eval)
getImpl (String key) = do
    liftIO $ dispatch key
    pure Void
getImpl _ = throwError $ wrongArgumentType ["String key"]

dispatch :: (?sink :: Sink) => Text -> IO ()
dispatch key = do
    print $ "Get: " <> key
    glue <- BS.readFile $ "./logic/glue/" <> unpack key <> ".glue"
    ?sink $ "(put store.cache \"" <> encodeUtf8 key <> "\" " <> glue <> ")"
