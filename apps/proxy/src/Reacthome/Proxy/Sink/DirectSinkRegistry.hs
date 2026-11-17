module Reacthome.Proxy.Sink.DirectSinkRegistry where

import Control.Concurrent.STM (atomically)
import Control.Monad.STM (STM)
import Data.UUID (UUID)
import ListT qualified as L
import Reacthome.Proxy.Sink.DirectSink (DirectSink)
import StmContainers.Map qualified as M
import Prelude hiding (all, lookup)

data DirectSinkRegistry = DirectSinkRegistry
    { lookup :: UUID -> STM (Maybe DirectSink)
    , all :: STM [(UUID, DirectSink)]
    , add :: UUID -> DirectSink -> IO ()
    , delete :: UUID -> IO ()
    }

makeDirectSinkRegistry :: IO DirectSinkRegistry
makeDirectSinkRegistry = do
    registry <- M.newIO

    let
        lookup uid = M.lookup uid registry
        all = L.toList $ M.listT registry
        add uid sink = atomically do M.insert sink uid registry
        delete uid = atomically do M.delete uid registry

    pure
        DirectSinkRegistry{..}
