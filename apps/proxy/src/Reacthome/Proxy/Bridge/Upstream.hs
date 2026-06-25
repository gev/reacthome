module Reacthome.Proxy.Bridge.Upstream where

import Control.Concurrent.STM (atomically)
import Data.ByteString.Lazy (ByteString)
import Data.Maybe (fromMaybe)
import Data.Text.Lazy.Encoding
import Glue.AST (AST (Object))
import Glue.Serialize (serializeAST)
import PubSub.Publisher (Publisher (..))
import PubSub.Revision (Revision (..))
import Reacthome.Proxy.Daemon.Actions (decodeAction)
import Reacthome.Proxy.Glue.PubSub.Types (GluePublisher)
import StmContainers.Map qualified as M

newtype Upstream = Upstream
    { publish :: ByteString -> IO ()
    }

makeUpstream :: (?pubsub :: GluePublisher) => IO Upstream
makeUpstream = do
    cache <- M.newIO
    let
        patch key delta = atomically do
            M.lookup key cache >>= \case
                Nothing -> do
                    M.insert delta key cache
                    pure delta
                Just value -> do
                    let patched = map (\(k, v) -> (k, fromMaybe v $ lookup k delta)) value
                    M.insert patched key cache
                    pure patched

        publish action =
            case decodeAction action of
                Just (uid, delta, version) -> do
                    value <- patch uid delta
                    let key = ["proxy", uid]
                        payload = encodeUtf8 $ serializeAST $ Object value
                        revision = Revision{..}
                    ?pubsub.publish key revision
                Nothing -> pure ()

    pure Upstream{..}
