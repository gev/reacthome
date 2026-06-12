module Reacthome.Logic.PubSub.Value where

data Value t v = Value
    { payload :: t
    , version :: v
    }
