module Reacthome.Proxy.Glue.Evaluator where

import Data.Text (Text)
import Data.UUID (UUID)
import Glue.Compile (compile)
import Glue.Error (GlueError (..))
import Glue.Eval (Eval, eval, runEvalSimple)
import Glue.IR (Env)
import Glue.Parse (parseGlue)
import Reacthome.Proxy.Assets (Assets)
import Reacthome.Proxy.Bridge.Downstream (Downstream)
import Reacthome.Proxy.Glue.PubSub.Types (GluePublisher)
import Reacthome.Proxy.Sink (Sink)

run ::
    ( ?session :: UUID
    , ?pubsub :: GluePublisher
    , ?assets :: Assets
    , ?sink :: Sink
    , ?downstream :: Downstream
    ) =>
    Text -> Env Eval -> IO (Either GlueError ())
run expression env = case parseGlue expression of
    Left err -> pure . Left $ GlueError err
    Right ast -> do
        let irTree = compile ast
        result <- runEvalSimple (eval irTree) env
        pure case result of
            Left err -> Left $ GlueError err
            _ -> Right ()
