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
dispatch key = do
    let path = T.splitOn "." key
    case path of
        "i18n" : _ -> ?store.lookup key
        "iconic" : _ -> ?store.lookup key
        "layout" : _ -> ?store.lookup key
        "lib" : _ -> ?store.lookup key
        "screen" : _ -> ?store.lookup key
        "widget" : _ -> ?store.lookup key
        _ -> do
            ?downstream.send $ getAction key
            pure Nothing
