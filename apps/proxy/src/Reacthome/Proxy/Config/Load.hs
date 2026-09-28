module Reacthome.Proxy.Config.Load where

import Control.Exception (IOException)
import Control.Exception.Base (try)
import Data.Text.IO qualified as T
import Glue.IR (extractValue, getValueFromIR)
import Reacthome.Proxy.Config.App
import Reacthome.Proxy.Error (ProxyError (..))
import Reacthome.Proxy.Glue.Env.Config
import Reacthome.Proxy.Glue.Evaluator (run)

loadConfig :: IO (Either ProxyError AppConfig)
loadConfig = do
    readResult <- try @IOException $ T.readFile "./proxy.glue"
    case readResult of
        Left ioErr -> pure $ Left $ ConfigError (show ioErr)
        Right glue -> do
            res <- run glue configEnv
            pure $ case res of
                Right value ->
                    case extractValue =<< getValueFromIR value of
                        Just config -> Right config
                        Nothing -> Left $ ConfigError "AppConfig required"
                Left e -> Left $ ConfigError (show e)
