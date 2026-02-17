module Reacthome.Logic.Core.Store where

data Nets k v m = Nets
    { store :: v -> m ()
    , remove :: v -> m ()
    , lookup :: k -> m (Maybe v)
    , all :: [v]
    }
