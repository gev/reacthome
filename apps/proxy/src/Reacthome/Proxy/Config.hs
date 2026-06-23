module Reacthome.Proxy.Config where

data AppConfig = AppConfig
    { server :: ServerConfig
    , daemon :: DaemonConfig
    , gluePath :: FilePath
    , assetsPath :: FilePath
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
