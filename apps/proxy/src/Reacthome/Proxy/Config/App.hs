module Reacthome.Proxy.Config.App where

data AppConfig = AppConfig
    { proxy :: ProxyConfig
    , daemon :: ClientConfig
    , relay :: ClientConfig
    , discovery :: DiscoveryConfig
    , assetsPath :: FilePath
    , gluePath :: FilePath
    , watch :: Bool
    }

data ProxyConfig = ProxyConfig
    { host :: String
    , port :: Int
    , daemon :: String
    }

data ClientConfig = ClientConfig
    { secure :: Bool
    , host :: String
    , port :: Int
    , uri :: String
    }
data DiscoveryConfig = DiscoveryConfig
    { announceInterval :: Int
    , announceGroup :: String
    , announcePort :: Int
    , probeGroup :: String
    , probePort :: Int
    , timeout :: Int
    }
