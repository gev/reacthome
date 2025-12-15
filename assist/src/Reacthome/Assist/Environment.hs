module Reacthome.Assist.Environment
    ( Environment (..)
    , GateConfig (..)
    ) where

import Data.ByteString (ByteString)
import Network.Socket (HostName, PortNumber)

data Environment = Environment
    { gate :: GateConfig
    , queueSize :: Int
    , jwksURL :: String
    , publicKeysUpdateInterval :: Int
    }

data GateConfig = GateConfig
    { host :: HostName
    , port :: PortNumber
    , protocol :: ByteString
    }
