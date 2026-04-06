module Reacthome.Logic.Glue.Controller where

import Data.ByteString (ByteString)
import Data.Text.Encoding (decodeUtf8')
import Reacthome.Logic.Glue.Evaluator (run)
import Reacthome.Logic.Glue.Sink (Sink)

runGlueController :: (?sink :: Sink) => ByteString -> IO ()
runGlueController message = do
    print message
    case decodeUtf8' message of
        Left err -> print err
        Right expression -> do
            run expression >>= \case
                Left err -> print err
                _ -> pure ()
