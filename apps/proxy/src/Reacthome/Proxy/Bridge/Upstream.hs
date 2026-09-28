module Reacthome.Proxy.Bridge.Upstream where

import Control.Monad (when)
import Data.ByteString.Lazy (ByteString)
import Data.Text (pack)
import Data.Text.Lazy.Encoding (encodeUtf8)
import Glue.AST (AST (..))
import Glue.Serialize (serializeAST)
import PubSub.Publisher (Publisher (..))
import PubSub.Revision (Revision (..))
import Reacthome.Proxy.Bridge.Cache (Cache (..))
import Reacthome.Proxy.Config.App (ProxyConfig (..))
import Reacthome.Proxy.Daemon.Actions.Decode (decodeAction)
import Reacthome.Proxy.Discovery (Discovery (..))
import Reacthome.Proxy.Glue.PubSub.Types (GluePublisher)

newtype Upstream = Upstream
    { publish :: ByteString -> IO ()
    }

makeUpstream ::
    ( ?cache :: Cache
    , ?pubsub :: GluePublisher
    , ?discovery :: Discovery
    ) =>
    ProxyConfig -> Upstream
makeUpstream config = Upstream{..}
  where
    publish action =
        case decodeAction action of
            Just (uid, delta, version) -> do
                value <- ?cache.patch uid delta
                when
                    (uid == daemon)
                    do ?discovery.justAnnounce (extractPayload value)
                let key = ["proxy", uid]
                    payload = encodeUtf8 $ serializeAST $ Object value
                    revision = Revision{..}
                ?pubsub.publish key revision
            Nothing -> pure ()

    daemon = pack config.daemon

    extractPayload =
        filter $ (`elem` ["title", "code"]) . fst
