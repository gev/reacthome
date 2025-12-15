module Reacthome.Assist.Repository.Answers
    ( makeAnswers
    ) where

import Control.Concurrent.MVar (newEmptyMVar, putMVar, takeMVar)
import Control.Monad.STM (atomically)
import Reacthome.Assist.Service.Dialog (Answers (..))
import StmContainers.Map (insert, lookup, newIO)
import Prelude hiding (lookup)

makeAnswers :: IO Answers
makeAnswers = do
    answers <- newIO

    let
        takeAnswer uid = do
            var <- newEmptyMVar
            atomically $ insert var uid answers
            takeMVar var

        putAnswer uid answer = do
            maybe
                (pure Nothing)
                (fmap Just . flip putMVar answer)
                =<< atomically (lookup uid answers)

    pure
        Answers
            { takeAnswer
            , putAnswer
            }
