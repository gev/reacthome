module Reacthome.Proxy.Glue.Dispatcher where

import Reacthome.Proxy.Bridge.Downstream (Downstream (..))
import Reacthome.Proxy.Daemon.Actions.Encode (actionGet)
import Reacthome.Proxy.Glue.PubSub.Types (GlueLookup)
import Reacthome.Proxy.Glue.Store (GlueStore (..))

dispatch ::
    ( ?downstream :: Downstream
    , ?store :: GlueStore
    ) =>
    GlueLookup
dispatch ["proxy", uid] = do
    ?downstream.send $ actionGet uid
    pure Nothing
dispatch key = ?store.lookup key
