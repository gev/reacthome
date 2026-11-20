module Reacthome.Proxy.Sink.RelaySinkRegistry where

import Control.Concurrent (threadDelay)
import Control.Concurrent.STM (atomically)
import Control.Monad (forever, void, when)
import Data.Maybe (isJust)
import Data.Time.Clock.POSIX (getPOSIXTime)
import Data.UUID (UUID)
import GHC.Conc (forkIO)
import ListT qualified as L
import Reacthome.Proxy.Sink
import StmContainers.Map qualified as M
import Prelude hiding (all, lookup)

data RelaySinkRegistry = RelaySinkRegistry
    { lookup :: UUID -> IO (Maybe Sink)
    , all :: IO [(UUID, Sink)]
    , add :: UUID -> Sink -> IO ()
    , has :: UUID -> IO Bool
    , actualize :: UUID -> IO ()
    }

makeRelaySinkRegistry :: IO RelaySinkRegistry
makeRelaySinkRegistry = do
    registry <- M.newIO
    timeouts <- M.newIO

    let
        lookup uid = atomically do
            M.lookup uid registry

        all = atomically do
            L.toList $ M.listT registry

        add uid sink = do
            ts <- now
            atomically do
                M.insert sink uid registry
                M.insert ts uid timeouts

        has uid = atomically do
            isJust <$> M.lookup uid registry

        actualize uid = do
            ts <- now
            atomically do
                M.insert ts uid timeouts

    void . forkIO $ forever do
        threadDelay 1_000_000
        timestamp <- now
        let
            isSinkNotActual sink = timestamp - sink >= 30
            invalidate (uid, sink) =
                when (isSinkNotActual sink) do
                    M.delete uid registry
        atomically do
            L.traverse_ invalidate $ M.listT timeouts

    pure
        RelaySinkRegistry{..}

now :: IO Int
now = round <$> getPOSIXTime
