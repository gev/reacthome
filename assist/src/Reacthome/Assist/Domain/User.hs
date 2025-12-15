module Reacthome.Assist.Domain.User
    ( User (..)
    , makeUser
    ) where

import Reacthome.Assist.Domain.Server.Id (ServerId)
import Reacthome.Assist.Domain.User.Id (UserId)

data User = User
    { id :: UserId
    , servers :: [ServerId]
    }
    deriving stock (Show)

makeUser ::
    UserId ->
    [ServerId] ->
    User
makeUser = User
