module Reacthome.Relay.Server where

import Control.Concurrent.Async (race)
import Control.Error (exceptT, throwE)
import Control.Monad (unless, when)
import Control.Monad.Trans.Class (lift)
import Reacthome.Relay (Uid)
import Reacthome.Relay.Dispatcher (RelayDispatcher (..))
import Reacthome.Relay.Error (RelayError (..), logError)
import Reacthome.Relay.Message (RelayMessageHeader (..), getMessageHeader, isMessageValid)
import WebSockets.Connection (WebSocketConnection (..))
import WebSockets.Options (WebSocketOptions)
import WebSockets.PendingConnection (WebSocketPendingConnection (..))
import Prelude hiding (lookup, take)

newtype RelayServer = RelayServer
    { accept :: Uid -> WebSocketPendingConnection -> IO ()
    }

makeRelayServer ::
    (?options :: WebSocketOptions) =>
    RelayDispatcher -> RelayServer
makeRelayServer dispatcher =
    let
        accept from pending = do
            let
                dispatchMessage message = exceptT logError pure do
                    unless (isMessageValid message) do
                        throwE $ InvalidMessage message
                    let header = getMessageHeader message
                    when (header.from /= from) do
                        throwE $ InvalidMessageSource header.from
                    lift (dispatcher.getSink header.to) >>= \case
                        Just !sendMessage -> lift $ sendMessage message
                        Nothing -> throwE $ NoPeersFound header.to

            pending.accept >>= \case
                Left !e -> logError $ WebSocketError from e
                Right !connection -> do
                    !tryReceiveMessage <- dispatcher.getSource from
                    -- print $ "Peer connected " <> show peer
                    res <-
                        either id id <$> race
                            do connection.runReceiveMessageLoop dispatchMessage
                            do connection.runSendMessageLoop tryReceiveMessage
                    logError $ WebSocketError from res
                    dispatcher.freeSource from
     in
        RelayServer{..}
