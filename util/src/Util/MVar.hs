module Util.MVar
    ( runModify
    , runRead
    ) where

import Control.Concurrent.MVar (MVar, putMVar, readMVar, takeMVar)

runModify :: MVar t -> (t -> t) -> IO ()
runModify var action = do
    value <- takeMVar var
    putMVar var (action value)

runRead :: MVar t -> (t -> b) -> IO b
runRead var action = do
    value <- readMVar var
    pure (action value)
