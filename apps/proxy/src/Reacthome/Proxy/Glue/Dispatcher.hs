module Reacthome.Proxy.Glue.Dispatcher where

import Control.Monad (when)
import Data.Maybe (isNothing)
import Reacthome.Proxy.Bridge.Downstream (Downstream (..))
import Reacthome.Proxy.Daemon.Actions.Encode (getAction)
import Reacthome.Proxy.Glue.PubSub.Types (GlueLookup)
import Reacthome.Proxy.Glue.Store (GlueStore (..))

dispatch ::
    ( ?downstream :: Downstream
    , ?store :: GlueStore
    ) =>
    GlueLookup
dispatch key = do
    glue <- ?store.lookup key
    when (isNothing glue) do
        ?downstream.send $ getAction key
    pure glue
