module Reacthome.Logic.PubSub.Versioned where

data Versioned t v = Versioned
    { payload :: t
    , version :: v
    }
