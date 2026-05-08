module Discovery.Config where

import Data.ByteString
import Discovery.Monitor
import Network.Socket

data AnnonceConfig = AnnonceConfig
    { group :: HostName
    , port :: PortNumber
    , message :: ByteString
    , interval :: Int
    , timeout :: Int
    , onMessage :: OnMessage
    }

data ProbeConfig = ProbeConfig
    { group :: HostName
    , port :: PortNumber
    , message :: ByteString
    , timeout :: Int
    }
