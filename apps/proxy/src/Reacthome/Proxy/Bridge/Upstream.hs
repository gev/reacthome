module Reacthome.Proxy.Bridge.Upstream where

import Data.ByteString.Lazy (ByteString)
import Data.Text.Lazy.Encoding
import Glue.AST (AST (Object))
import Glue.Serialize (serializeAST)
import PubSub.Publisher (Publisher (..))
import PubSub.Revision (Revision (..))
import Reacthome.Proxy.Bridge.Cache (Cache (..))
import Reacthome.Proxy.Daemon.Actions.Decode (decodeAction)
import Reacthome.Proxy.Glue.PubSub.Types (GluePublisher)

newtype Upstream = Upstream
    { publish :: ByteString -> IO ()
    }

makeUpstream ::
    ( ?cache :: Cache
    , ?pubsub :: GluePublisher
    ) =>
    Upstream
makeUpstream =
    let
        publish action =
            case decodeAction action of
                Just (uid, delta, version) -> do
                    value <- ?cache.patch uid delta
                    let key = ["proxy", uid]
                        payload = encodeUtf8 $ serializeAST $ Object value
                        revision = Revision{..}
                    ?pubsub.publish key revision
                Nothing -> pure ()
     in
        Upstream{..}
