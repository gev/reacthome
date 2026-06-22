module Reacthome.Proxy.Config where

data Config = Config
    { host :: String
    , port :: Int
    , gluePath :: FilePath
    , assetsPath :: FilePath
    }
