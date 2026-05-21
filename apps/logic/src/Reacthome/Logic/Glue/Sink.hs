module Reacthome.Logic.Glue.Sink where

import Data.ByteString.Lazy (ByteString)
import Data.Text (Text)

type Sink = ByteString -> IO ()

data SinkRegistry = SinkRegistry
    { add :: Text -> Sink -> IO ()
    , delete :: Text -> IO ()
    }

makeSinkRegistry :: IO SinkRegistry
makeSinkRegistry = do
    let
        add = undefined
        delete = undefined
    pure SinkRegistry{..}
