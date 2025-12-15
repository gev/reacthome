module Reacthome.Assist.Domain.User.Id
    ( UserId (..)
    , makeUserId
    , makeRandomUserId
    ) where

import Data.Hashable (Hashable)
import Data.UUID (UUID)
import Data.UUID.V4 (nextRandom)

newtype UserId = UserId {value :: UUID}
    deriving stock (Show)
    deriving newtype (Eq, Hashable)

makeUserId :: UUID -> UserId
makeUserId = UserId

makeRandomUserId :: IO UserId
makeRandomUserId = UserId <$> nextRandom
