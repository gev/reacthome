module Reacthome.Logic.Glue.Lib.Vision.Get where

import Data.Text (Text)
import Glue.Eval (Eval, liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Reacthome.Logic.Glue.Publisher (GluePublisher)
import Reacthome.Logic.PubSub.Publisher (Publisher (..))

get :: (?pubsub :: GluePublisher) => IR Eval
get = NativeFunc getImpl

getImpl :: (?pubsub :: GluePublisher) => IR Eval -> Eval (IR Eval)
getImpl (String key) = do
    liftIO $ dispatch key
    pure Void
getImpl _ = throwError $ wrongArgumentType ["Get function requres `DottedSymbol` store and `String` key parameters"]

dispatch :: (?pubsub :: GluePublisher) => Text -> IO ()
dispatch key = do
    ?pubsub.subscribe "" key
