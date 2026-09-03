module Reacthome.Proxy.Daemon.Actions.Encode
where

import Data.Aeson qualified as A
import Data.Aeson.KeyMap qualified as A
import Data.Scientific (fromFloatDigits)
import Data.Text (Text)
import Data.Vector qualified as V

actionGet :: Text -> A.Object
actionGet uid =
    A.fromList
        [ ("type", "get")
        , ("state", A.Array $ V.fromList [A.String uid])
        ]

actionState :: A.Value -> Text -> A.Object
actionState action uid =
    A.fromList
        [ ("type", action)
        , ("id", A.String uid)
        ]

actionValue :: A.Value -> A.Key -> Double -> Text -> A.Object
actionValue action key value uid =
    A.fromList
        [ ("type", action)
        , ("id", A.String uid)
        , (key, A.Number $ fromFloatDigits value)
        ]
