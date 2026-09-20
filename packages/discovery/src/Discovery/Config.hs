module Discovery.Config where

import Network.Socket

data AnnounceConfig = AnnounceConfig
    { group :: HostName
    , port :: PortNumber
    , interval :: Int
    , timeout :: Int
    }

data ProbeConfig = ProbeConfig
    { group :: HostName
    , port :: PortNumber
    , timeout :: Int
    }
