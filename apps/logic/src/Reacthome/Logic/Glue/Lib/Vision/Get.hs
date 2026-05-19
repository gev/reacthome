module Reacthome.Logic.Glue.Lib.Vision.Get where

import Data.ByteString.Lazy qualified as L
import Data.Text (Text, unpack)
import Data.Text qualified as T
import Data.Text.Encoding (encodeUtf8)
import Glue.Eval (Eval, liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Reacthome.Logic.Glue.Sink (Sink)

get :: (?sink :: Sink) => IR Eval
get = NativeFunc getImpl

getImpl :: (?sink :: Sink) => IR Eval -> Eval (IR Eval)
getImpl store = pure $ NativeFunc (getImpl' store)

getImpl' :: (?sink :: Sink) => IR Eval -> IR Eval -> Eval (IR Eval)
getImpl' (DottedSymbol store) (String key) = do
    liftIO $ dispatch store key
    pure Void
getImpl' _ _ = throwError $ wrongArgumentType ["Get function requres `DottedSymbol` store and `String` key parameters"]

dispatch :: (?sink :: Sink) => [Text] -> Text -> IO ()
dispatch store key = do
    glue <- L.readFile $ "./apps/logic/glue/" <> unpack key <> ".glue"
    ?sink $ "(put " <> enc (T.intercalate "." store) <> " \"" <> enc key <> "\" " <> glue <> ")"
  where
    enc = L.fromStrict . encodeUtf8
