module Reacthome.Proxy.Glue.Evaluator where

import Data.Text (Text)
import Data.UUID (UUID)
import Glue.Compile (compile)
import Glue.Error (GlueError (..))
import Glue.Eval (eval, runEvalSimple)
import Glue.Parse (parseGlue)
import Reacthome.Proxy.Assets (Assets)
import Reacthome.Proxy.Glue.Env (env)
import Reacthome.Proxy.Glue.Publisher (GluePublisher)
import Reacthome.Proxy.Sink (Sink)

run ::
    ( ?session :: UUID
    , ?pubsub :: GluePublisher
    , ?assets :: Assets
    , ?sink :: Sink
    ) =>
    Text -> IO (Either GlueError ())
run expression = case parseGlue expression of
    Left err -> pure . Left $ GlueError err
    Right ast -> do
        let irTree = compile ast
        result <- runEvalSimple (eval irTree) env
        pure case result of
            Left err -> Left $ GlueError err
            _ -> Right ()
