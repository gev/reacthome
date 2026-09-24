module Reacthome.Proxy.Discovery where

import Control.Concurrent (forkIO)
import Data.ByteString (ByteString)
import Data.ByteString.Lazy qualified as L
import Data.Functor (void)
import Data.IORef (newIORef, readIORef, writeIORef)
import Data.Text (Text)
import Data.Text.Lazy.Encoding qualified as E
import Discovery.Announcer (announce)
import Discovery.Config (AnnounceConfig (..), ProbeConfig (..))
import Discovery.Responder (respond)
import Glue.AST (AST (..))
import Glue.Serialize (serializeAST)
import Reacthome.Proxy.Config (DiscoveryConfig (..), ProxyConfig (..))

data Discovery = Discovery
    { justAnnounce :: Text -> Text -> Text -> IO ()
    , runAnnouncer :: IO ()
    , justRespond :: IO ()
    }

makeProxyDiscovery ::
    DiscoveryConfig -> ProxyConfig -> IO Discovery
makeProxyDiscovery config proxy = do
    announceMessage <- newIORef Nothing

    let getAnnounceMessage = readIORef announceMessage

    let justAnnounce uid title code =
            writeIORef announceMessage do
                Just (makeAnnounceMessage uid title code)

    let ?announce =
            AnnounceConfig
                { group = config.announceGroup
                , port = fromIntegral config.announcePort
                , interval = config.announceInterval
                , timeout = config.timeout
                }

    let runAnnouncer = void do
            forkIO
                (announce getAnnounceMessage)

    let ?probe =
            ProbeConfig
                { group = config.probeGroup
                , port = fromIntegral config.probePort
                , timeout = config.timeout
                }

    let justRespond = void do
            forkIO
                ( respond \msg ->
                    if msg == probeMessage
                        then getAnnounceMessage
                        else pure Nothing
                )

    pure Discovery{..}
  where
    -- \| Generates and serializes a UDP announcement for the proxy server.
    --
    --            (discovery
    --                :version 1
    --                :service (
    --                    :version 0
    --                    :id "node-4f8a2c1e"
    --                    :type "legacy-daemon-proxy"
    --                    :scheme "ws"
    --                    :port 3005
    --                    :uri "/node-4f8a2c1e"
    --                    :title "service-title"
    --                    :code "service-code"
    --                )
    --            )
    --
    makeAnnounceMessage uid title code = serialize do
        List
            [ Symbol "discovery"
            , Object
                [ ("version", Integer 1)
                ,
                    ( "service"
                    , Object
                        [ ("version", Integer 0)
                        , ("id", String uid)
                        , ("type", String "legacy-daemon-proxy")
                        , ("scheme", String "ws")
                        , ("port", Integer proxy.port)
                        , ("uri", String $ "/" <> uid)
                        , ("title", String title)
                        , ("code", String code)
                        ]
                    )
                ]
            ]

    probeMessage = serialize do
        List
            [ Symbol "probe"
            , Object [("version", Integer 1)]
            ]

    serialize :: AST -> ByteString
    serialize = L.toStrict . E.encodeUtf8 . serializeAST
