module Reacthome.Assist.Domain.Server.Id
    ( ServerId (..)
    ) where

import Data.UUID (UUID)

newtype ServerId = ServerId {value :: UUID}
    deriving stock (Eq, Show)
