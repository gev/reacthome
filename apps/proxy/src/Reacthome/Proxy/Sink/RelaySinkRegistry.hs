module Reacthome.Proxy.Sink.RelaySinkRegistry where

import Control.Concurrent (threadDelay)
import Control.Concurrent.STM (STM, atomically)
import Control.Monad (forever, void, when)
import Data.UUID (UUID)
import GHC.Conc (forkIO)
import ListT qualified as L
import Reacthome.Proxy.Sink.RelaySink (RelaySink (..), now)
import StmContainers.Map qualified as M
import Prelude hiding (all, lookup)

data RelaySinkRegistry = RelaySinkRegistry
    { lookup :: UUID -> STM (Maybe RelaySink)
    , all :: STM [(UUID, RelaySink)]
    , add :: UUID -> RelaySink -> IO ()
    , delete :: UUID -> IO ()
    , reset :: IO ()
    }

makeRelaySinkRegistry :: IO RelaySinkRegistry
makeRelaySinkRegistry = do
    registry <- M.newIO

    let
        lookup uid = M.lookup uid registry
        all = L.toList $ M.listT registry
        add uid sink = atomically do M.insert sink uid registry
        delete uid = atomically do M.delete uid registry
        reset = atomically do M.reset registry

    void . forkIO $ forever do
        threadDelay 10_000_000
        timestamp <- now
        let
            isSinkNotActual sink =
                timestamp - sink.timestamp >= 30
            invalidate (uid, sink) =
                when (isSinkNotActual sink) do
                    M.delete uid registry
        atomically do
            L.traverse_ invalidate $ M.listT registry

    pure
        RelaySinkRegistry{..}
