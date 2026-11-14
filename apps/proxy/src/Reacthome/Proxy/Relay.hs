module Reacthome.Proxy.Relay where

import Control.Concurrent (threadDelay)
import Control.Monad (guard, void)
import Data.ByteString (fromStrict)
import Data.IORef (modifyIORef, newIORef)
import Data.Set (empty, insert)
import Data.UUID (fromByteString)
import Reacthome.Proxy.Assets (Assets)
import Reacthome.Proxy.Bridge.Downstream (Downstream)
import Reacthome.Proxy.Config.App (ClientConfig (..), ProxyConfig (..))
import Reacthome.Proxy.Error (ProxyError (InvalidPeer), logError)
import Reacthome.Proxy.Glue.Controller
import Reacthome.Proxy.Glue.PubSub.Types (GluePublisher)
import Reacthome.Proxy.Sink (SinkRegistry)
import Reacthome.Relay.Message (RelayMessageHeader (..), getMessageHeader, isMessageValid)
import WebSockets.Client (runWebSocketClient)
import WebSockets.Options (defaultWebSocketOptions)

runProxyRelay ::
    ( ?pubsub :: GluePublisher
    , ?assets :: Assets
    , ?sinks :: SinkRegistry
    , ?downstream :: Downstream
    ) =>
    ClientConfig -> ProxyConfig -> IO ()
runProxyRelay config proxy = do
    peers <- newIORef empty
    let uri = "/v1?peer=" <> proxy.daemon
    print uri
    let ?options = defaultWebSocketOptions
    let ?sink =
            \message -> do
                guard $ isMessageValid message
                let header = getMessageHeader message
                case fromByteString (fromStrict header.from) of
                    Just uid -> do
                        let ?session = uid
                        modifyIORef peers (insert ?session)
                        -- controller message
                        print message
                    Nothing -> logError $ InvalidPeer header.from
    let ?source = pure (Nothing, threadDelay 100_000_000_000 >> pure "")
    void $
        runWebSocketClient
            config.secure
            config.host
            config.port
            uri
