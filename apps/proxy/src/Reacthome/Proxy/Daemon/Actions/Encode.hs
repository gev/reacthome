module Reacthome.Proxy.Daemon.Actions.Encode
where

import Data.Aeson qualified as A
import Data.Aeson.KeyMap qualified as A
import Data.Text (Text)
import Data.Vector qualified as V

actionGet :: Text -> A.Object
actionGet uid =
    A.fromList
        [ ("type", "get")
        , ("state", A.Array $ V.fromList [A.String uid])
        ]

actionOn :: Text -> A.Object
actionOn uid =
    A.fromList
        [ ("type", "ACTION_ON")
        , ("id", A.String uid)
        ]

actionOff :: Text -> A.Object
actionOff uid =
    A.fromList
        [ ("type", "ACTION_OFF")
        , ("id", A.String uid)
        ]
