module Reacthome.Proxy.Sink.DirectSinkRegistry where

import Control.Concurrent.STM (atomically)
import Data.UUID (UUID)
import ListT qualified as L
import Reacthome.Proxy.Sink (Sink)
import StmContainers.Map qualified as M
import Prelude hiding (all, lookup)

data DirectSinkRegistry = DirectSinkRegistry
    { lookup :: UUID -> IO (Maybe Sink)
    , all :: IO [(UUID, Sink)]
    , add :: UUID -> Sink -> IO ()
    , delete :: UUID -> IO ()
    }

makeDirectSinkRegistry :: IO DirectSinkRegistry
makeDirectSinkRegistry = do
    registry <- M.newIO

    let
        lookup uid = atomically do
            M.lookup uid registry

        all = atomically do
            L.toList $ M.listT registry

        add uid sink = atomically do
            M.insert sink uid registry

        delete uid = atomically do
            M.delete uid registry

    pure
        DirectSinkRegistry{..}
