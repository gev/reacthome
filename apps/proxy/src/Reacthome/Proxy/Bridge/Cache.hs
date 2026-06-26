module Reacthome.Proxy.Bridge.Cache where

import Control.Concurrent.STM (atomically)
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import Glue.AST (AST)
import StmContainers.Map qualified as M

newtype Cache = Cache
    { patch :: Text -> [(Text, AST)] -> IO [(Text, AST)]
    }

makeCache :: IO Cache
makeCache = do
    cache <- M.newIO
    let
        patch key delta = atomically do
            M.lookup key cache >>= \case
                Nothing -> do
                    M.insert delta key cache
                    pure delta
                Just value -> do
                    let patched = map (\(k, v) -> (k, fromMaybe v $ lookup k delta)) value
                    M.insert patched key cache
                    pure patched

    pure Cache{..}
