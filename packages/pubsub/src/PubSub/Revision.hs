module PubSub.Revision where

data Revision t v = Revision
    { payload :: t
    , version :: v
    }
    deriving (Show)
