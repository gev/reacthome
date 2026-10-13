module Reacthome.Proxy.Daemon.Actions.Encode
where

import Data.Aeson qualified as A
import Data.Aeson.KeyMap qualified as A
import Data.Scientific (fromFloatDigits)
import Data.Text (Text)
import Data.Vector qualified as V

getAction :: Text -> A.Object
getAction uid =
    A.fromList
        [ ("type", "get")
        , ("state", A.Array $ V.fromList [A.String uid])
        ]

simpleAction :: A.Value -> Text -> A.Object
simpleAction action uid =
    A.fromList
        [ ("type", action)
        , ("id", A.String uid)
        ]

valueAction :: A.Value -> A.Key -> Double -> Text -> A.Object
valueAction action key value uid =
    A.fromList
        [ ("type", action)
        , ("id", A.String uid)
        , (key, A.Number $ fromFloatDigits value)
        ]
