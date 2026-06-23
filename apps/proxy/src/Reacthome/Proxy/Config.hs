module Reacthome.Proxy.Config where

data DaemonConfig = DaemonConfig
    { daemon :: String
    , daemonHost :: String
    , daemonPort :: Int
    }

data AppConfig = AppConfig
    { listenHost :: String
    , listenPort :: Int
    , gluePath :: FilePath
    , assetsPath :: FilePath
    }
