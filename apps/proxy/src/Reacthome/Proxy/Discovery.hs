module Reacthome.Proxy.Discovery where

import Control.Concurrent (forkIO)
import Data.ByteString.Lazy qualified as L
import Data.Functor (void)
import Data.IORef (newIORef, readIORef, writeIORef)
import Data.Text (Text, pack)
import Data.Text.Lazy.Encoding qualified as E
import Discovery.Announcer (announce)
import Discovery.Config (AnnounceConfig (..), ProbeConfig (..))
import Discovery.Responder (respond)
import Glue.AST (AST (..))
import Glue.Serialize (serializeAST)
import Reacthome.Proxy.Config.App (DiscoveryConfig (..), ProxyConfig (..))

data Discovery = Discovery
    { justAnnounce :: [(Text, AST)] -> IO ()
    , runAnnouncer :: IO ()
    , runResponder :: IO ()
    }

makeProxyDiscovery ::
    DiscoveryConfig -> ProxyConfig -> IO Discovery
makeProxyDiscovery config proxy = do
    announceMessage <- newIORef Nothing

    let getAnnounceMessage = readIORef announceMessage

    let justAnnounce =
            writeIORef announceMessage . Just . makeAnnounceMessage

    let ?announce =
            AnnounceConfig
                { group = config.announceGroup
                , port = fromIntegral config.announcePort
                , interval = config.announceInterval
                , timeout = config.timeout
                }

    let runAnnouncer = announce getAnnounceMessage

    let ?probe =
            ProbeConfig
                { group = config.probeGroup
                , port = fromIntegral config.probePort
                , timeout = config.timeout
                }

    let runResponder = void $ forkIO do
            respond \msg ->
                if msg == probeMessage
                    then getAnnounceMessage
                    else pure Nothing

    pure Discovery{..}
  where
    makeAnnounceMessage payload = serialize do
        let spec =
                [ ("version", Integer 0)
                , ("id", String daemon)
                , ("type", String "legacy-daemon-proxy")
                , ("scheme", String "ws")
                , ("port", Integer proxy.port)
                , ("uri", String $ "/" <> daemon)
                ]
        List
            [ Symbol "discovery"
            , Object
                [ ("version", Integer 1)
                , ("service", Object (spec <> payload))
                ]
            ]

    probeMessage = serialize do
        List
            [ Symbol "probe"
            , Object [("version", Integer 1)]
            ]

    serialize = L.toStrict . E.encodeUtf8 . serializeAST

    daemon = pack proxy.daemon
