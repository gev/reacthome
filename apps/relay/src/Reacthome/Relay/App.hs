module Reacthome.Relay.App (
    application,
) where

import Control.Monad (join)
import Data.ByteString (ByteString, toStrict)
import Data.Function ((&))
import Data.Text (Text, pack)
import Data.Text.Encoding (decodeUtf8', encodeUtf8)
import Data.UUID (fromText, toByteString)
import Network.HTTP.Types (Query, decodePath)
import Reacthome.Relay.Dispatcher (makeRelayDispatcher)
import Reacthome.Relay.Error (RelayError (..), logError)
import Reacthome.Relay.Server (RelayServer (..), makeRelayServer)
import WebSockets.Options (WebSocketOptions)
import WebSockets.PendingConnection (WebSocketPendingConnection (..))
import WebSockets.Server (WebSocketServerApplication)
import Prelude hiding (length, splitAt, tail)

application ::
    (?options :: WebSocketOptions) =>
    WebSocketServerApplication
application pending = do
    let (path, query) = decodePath pending.path
    pending & case path of
        ["v1"] -> acceptV1 query
        [version] -> rejectWith $ InvalidVersion version
        _ -> rejectWith $ InvalidUri pending.path

acceptV1 ::
    (?options :: WebSocketOptions) =>
    Query -> WebSocketPendingConnection -> IO ()
acceptV1 query pending = do
    dispatcher <- makeRelayDispatcher
    let server = makeRelayServer dispatcher
    pending & case lookupQuery "peer" query of
        Just peer -> case fromText peer of
            Just uid -> server.accept $ toStrict $ toByteString uid
            _ -> rejectWith $ InvalidPeer peer
        _ -> rejectWith NoPeerPresent

rejectWith :: RelayError -> WebSocketPendingConnection -> IO ()
rejectWith err pending = do
    logError err
    pending.reject $ encodeUtf8 . pack $ show err

lookupQuery :: ByteString -> Query -> Maybe Text
lookupQuery key query =
    case decodeUtf8' <$> join (lookup key query) of
        Just (Right value) -> Just value
        _ -> Nothing
