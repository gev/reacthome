module Reacthome.Proxy.Sink where

import Control.Concurrent.STM (atomically)
import Data.ByteString.Lazy (ByteString)
import Data.UUID (UUID)
import StmContainers.Map qualified as M

type Sink = ByteString -> IO ()

data SinkRegistry = SinkRegistry
    { lookup :: UUID -> IO (Maybe Sink)
    , add :: UUID -> Sink -> IO ()
    , delete :: UUID -> IO ()
    }

makeSinkRegistry :: IO SinkRegistry
makeSinkRegistry = do
    registry <- M.newIO
    pure
        SinkRegistry
            { lookup = \uid -> atomically do M.lookup uid registry
            , add = \uid sink -> atomically do M.insert sink uid registry
            , delete = \uid -> atomically do M.delete uid registry
            }
