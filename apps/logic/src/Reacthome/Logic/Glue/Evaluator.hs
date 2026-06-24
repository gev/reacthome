module Reacthome.Logic.Glue.Evaluator where

import Data.Text (Text)
import Data.UUID (UUID)
import Glue.Compile (compile)
import Glue.Error (GlueError (..))
import Glue.Eval (eval, runEvalSimple)
import Glue.Parse (parseGlue)
import Reacthome.Logic.Glue.Env (env)
import Reacthome.Logic.Glue.PubSub.Publisher (GluePublisher)
import Reacthome.Logic.Glue.Sink (Sink)

run ::
    ( ?session :: UUID
    , ?pubsub :: GluePublisher
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
