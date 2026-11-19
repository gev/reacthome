module Reacthome.Proxy.Glue.Dispatcher where

import Data.Text qualified as T
import Reacthome.Proxy.Bridge.Downstream (Downstream (..))
import Reacthome.Proxy.Daemon.Actions.Encode (getAction)
import Reacthome.Proxy.Glue.PubSub.Types (GlueLookup)
import Reacthome.Proxy.Glue.Store (GlueStore (..))

dispatch ::
    ( ?downstream :: Downstream
    , ?store :: GlueStore
    ) =>
    GlueLookup
dispatch key =
    case T.splitAt 6 key of
        ("proxy.", uid) -> do
            ?downstream.send $ getAction uid
            pure Nothing
        _ -> ?store.lookup key
