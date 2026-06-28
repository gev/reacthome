module Reacthome.Proxy.Config where

data AppConfig = AppConfig
    { server :: ServerConfig
    , daemon :: DaemonConfig
    , gluePath :: FilePath
    , assets :: AssetsConfig
    }

data ServerConfig = ServerConfig
    { host :: String
    , port :: Int
    }

data DaemonConfig = DaemonConfig
    { uid :: String
    , host :: String
    , port :: Int
    , uri :: String
    }

data AssetsConfig = AssetsConfig
    { path :: String
    , proxy :: String
    }
