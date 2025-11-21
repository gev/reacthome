module Reacthome.Relay.Client where

import Control.Concurrent (forkIO, threadDelay)
import Control.Concurrent.STM (atomically, flushTBQueue, newTBQueueIO, writeTBQueue)
import Control.Monad (forever, void)
import Reacthome.Relay.Message (RelayMessage, serializeMessage)
import Reacthome.Relay.Stat (RelayHits (..), RelayStat (..))
import Web.WebSockets.Connection (WebSocketConnection (..))
import Prelude hiding (splitAt, tail)

data RelayClient = RelayClient
    { start :: IO ()
    , send :: RelayMessage -> IO ()
    }

makeRelayClient :: RelayStat -> WebSocketConnection -> IO RelayClient
makeRelayClient stat connection = do
    queue <- newTBQueueIO 100

    void . forkIO $ forever do
        messages <- atomically $ flushTBQueue queue
        connection.sendMessages messages
        stat.tx.hit $ length messages
        threadDelay 100

    let
        start =
            void $ forkIO $ forever do
                void connection.receiveMessage
                stat.rx.hit 1

        -- send = atomically . writeTBQueue queue . serializeMessage
        send message = do
            connection.sendMessage $ serializeMessage message
            stat.tx.hit 1

    pure RelayClient{..}
