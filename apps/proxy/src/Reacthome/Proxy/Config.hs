module Reacthome.Proxy.Config where

import Data.Text (Text)

data AppConfig = AppConfig
    { proxy :: ProxyConfig
    , daemon :: DaemonConfig
    , discovery :: DiscoveryConfig
    , gluePath :: FilePath
    , assets :: AssetsConfig
    }

data ProxyConfig = ProxyConfig
    { host :: String
    , port :: Int
    , daemon :: Text
    }

data DaemonConfig = DaemonConfig
    { host :: String
    , port :: Int
    , uri :: String
    }

data AssetsConfig = AssetsConfig
    { path :: FilePath
    , proxy :: String
    }

data DiscoveryConfig = DiscoveryConfig
    { announceInterval :: Int
    , announceGroup :: String
    , announcePort :: Int
    , probeGroup :: String
    , probePort :: Int
    , timeout :: Int
    }
