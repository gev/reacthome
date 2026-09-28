module Reacthome.Proxy.Glue.Evaluator where

import Data.Text (Text)
import Glue.Compile (compile)
import Glue.Error (GlueError (..))
import Glue.Eval (Eval, eval, runEvalSimple)
import Glue.IR (Env, IR)
import Glue.Parse (parseGlue)

run :: Text -> Env Eval -> IO (Either GlueError (IR Eval))
run expression env = case parseGlue expression of
    Left err -> pure . Left $ GlueError err
    Right ast -> do
        let irTree = compile ast
        result <- runEvalSimple (eval irTree) env
        pure case result of
            Left err -> Left $ GlueError err
            Right (res, _) -> Right res
