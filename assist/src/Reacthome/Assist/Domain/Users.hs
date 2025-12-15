module Reacthome.Assist.Domain.Users
    ( Users (..)
    ) where

import Reacthome.Assist.Domain.User (User)
import Reacthome.Assist.Domain.User.Id (UserId)

newtype Users = Users
    { findById :: UserId -> Either String User
    }
