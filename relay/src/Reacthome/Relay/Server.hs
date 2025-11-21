module Reacthome.Relay.Server where

import Control.Concurrent (forkIO, threadDelay)
import Control.Concurrent.STM (atomically, dupTChan, newBroadcastTChan, newTVarIO, readTVar, retry, tryReadTChan, writeTChan, writeTVar)
import Control.Exception (catch)
import Control.Monad (forever, unless, void, when)
import Data.ByteString (toStrict)
import Data.UUID (UUID, toByteString)
import Reacthome.Relay.Error (RelayError (..), logError)
import Reacthome.Relay.Message (RelayMessage (..), parseMessage, serializeMessage)
import StmContainers.Map (insert, lookup, newIO)
import Web.WebSockets.Connection (WebSocketConnection (..))
import Web.WebSockets.Error (WebSocketError)
import Web.WebSockets.PendingConnection (WebSocketPendingConnection (..))
import Prelude hiding (lookup, splitAt, tail, take)

newtype RelayServer = RelayServer
    { accept :: WebSocketPendingConnection -> UUID -> IO ()
    }

makeRelayServer :: IO RelayServer
makeRelayServer = do
    repository <- newIO
    count <- newTVarIO 0
    let
        accept pending peer = do
            let from = toStrict $ toByteString peer
            chan <- atomically do
                maybe
                    do
                        ch <- newBroadcastTChan
                        insert ch from repository
                        dupTChan ch
                    dupTChan
                    =<< lookup from repository

            catch @WebSocketError
                do
                    connection <- pending.accept
                    runTx connection chan
                    runRx connection from
                do logError . WebSocketError from

        runTx connection chan = void . forkIO $ forever do
            messages <- atomically do
                writeTVar count 0
                readAll chan []
            unless (null messages) do
                print $ length messages
                connection.sendMessages $ reverse messages
                threadDelay 1_000

        readAll chan xs =
            maybe
                do pure xs
                do readAll chan . (: xs)
                =<< tryReadTChan chan

        runRx connection from = do
            catch @WebSocketError
                do
                    forever do
                        message <- connection.receiveMessage
                        catch @RelayError
                            do
                                let message' = parseMessage message
                                send
                                    message'.peer
                                    RelayMessage
                                        { peer = from
                                        , content = message'.content
                                        }
                            logError
                do
                    logError . WebSocketError from

        send to message =
            maybe
                do
                    logError $ NoPeersFound to
                do
                    \chan -> atomically do
                        count' <- readTVar count
                        when (count' == bound) retry
                        writeTChan chan $ serializeMessage message
                        writeTVar count $ count' + 1
                =<< atomically do
                    lookup to repository

    pure RelayServer{..}

headerLength :: Int
headerLength = 16

bound :: Int
bound = 1_000
