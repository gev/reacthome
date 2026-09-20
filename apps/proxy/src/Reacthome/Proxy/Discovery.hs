module Reacthome.Proxy.Discovery where

import Control.Concurrent (forkIO)
import Data.ByteString (ByteString)
import Data.ByteString.Lazy qualified as L
import Data.Functor (void)
import Data.String (fromString)
import Data.Text.Lazy.Encoding qualified as E
import Discovery.Announcer (announce)
import Discovery.Config (AnnounceConfig (..), ProbeConfig (..))
import Discovery.Responder (respond)
import Glue.AST (AST (..))
import Glue.Serialize (serializeAST)
import Reacthome.Proxy.Config (DiscoveryConfig (..), ProxyConfig (..))

runProxyDiscovery :: DiscoveryConfig -> ProxyConfig -> IO ()
runProxyDiscovery config proxy = do
    let announceMessage = makeAnnounceMessage proxy

    let ?announce =
            AnnounceConfig
                { group = config.announceGroup
                , port = fromIntegral config.announcePort
                , interval = config.announceInterval
                , timeout = config.timeout
                }
    void $
        forkIO
            (announce announceMessage)

    let ?probe =
            ProbeConfig
                { group = config.probeGroup
                , port = fromIntegral config.probePort
                , timeout = config.timeout
                }
    void $
        forkIO
            ( respond \msg ->
                if msg == probeMessage
                    then Just announceMessage
                    else Nothing
            )

makeAnnounceMessage :: ProxyConfig -> ByteString
makeAnnounceMessage proxy = serialize do
    List
        [ Symbol "discovery"
        , Object
            [ ("version", Integer 1)
            ,
                ( "service"
                , Object
                    [ ("version", Integer 0)
                    , ("id", String uid)
                    , ("scheme", String "ws")
                    , ("port", Integer proxy.port)
                    , ("uri", String uri)
                    ]
                )
            ]
        ]
  where
    uid = fromString proxy.daemon
    uri = "/" <> uid

probeMessage :: ByteString
probeMessage = serialize do
    List
        [ Symbol "probe"
        , Object [("version", Integer 1)]
        ]

serialize :: AST -> ByteString
serialize = L.toStrict . E.encodeUtf8 . serializeAST
