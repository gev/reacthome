module Reacthome.Assist.Dialog.Gate
    ( getAnswer
    , setAnswer
    ) where

import Data.UUID.V4 (nextRandom)
import Reacthome.Assist.Controller.Dialog.Query (sendQuery)
import Reacthome.Assist.Domain.Server.Id (ServerId)
import Reacthome.Assist.Service.Dialog (Answers (..), GetAnswer, SetAnswer, pack)
import Reacthome.Gate.Connection.Pool (GateConnectionPool)
import Prelude hiding (lookup)

getAnswer ::
    ( ?answers :: Answers
    , ?gateConnectionPool :: GateConnectionPool
    ) =>
    ServerId -> GetAnswer
getAnswer sid query = do
    uid <- nextRandom
    sendQuery sid $ pack uid query
    ?answers.takeAnswer uid

setAnswer :: (?answers :: Answers) => SetAnswer
setAnswer uid answer =
    maybe (print $ "Could not put answer with id " <> show uid <> " into answers") pure
        =<< ?answers.putAnswer uid answer
