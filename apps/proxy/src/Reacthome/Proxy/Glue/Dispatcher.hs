module Reacthome.Proxy.Glue.Dispatcher where

import Data.Aeson qualified as A
import Data.Aeson.KeyMap qualified as A
import Data.Vector qualified as V
import Reacthome.Proxy.Bridge (Downstream (..))
import Reacthome.Proxy.Glue.PubSub.GlueOp (GluePubSubGetter)
import Reacthome.Proxy.Glue.Store (GlueStore (..))

dispatch ::
    ( ?downstream :: Downstream
    , ?store :: GlueStore
    ) =>
    GluePubSubGetter
dispatch ["proxy", id'] = do
    let json =
            A.Object $
                A.fromList
                    [ ("type", "get")
                    , ("state", A.Array $ V.fromList [A.String id'])
                    ]
    let message = A.encode json
    ?downstream.send message
    pure Nothing
dispatch key = ?store.get key
