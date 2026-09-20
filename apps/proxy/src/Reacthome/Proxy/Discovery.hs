module Reacthome.Proxy.Discovery where

import Control.Monad (forever)
import Data.Aeson.KeyMap qualified as A
import Data.Aeson.Types qualified as A
import GHC.Conc.IO (threadDelay)
import Reacthome.Proxy.Config (DiscoveryConfig (..))

discoveryMessage :: A.KeyMap A.Value
discoveryMessage = A.fromList [("type", "discovery")]

runProxyDiscovery ::
    DiscoveryConfig -> IO ()
runProxyDiscovery config = forever do
    threadDelay $ config.announceInterval * 1_000_000
