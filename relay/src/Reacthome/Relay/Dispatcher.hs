module Reacthome.Relay.Dispatcher where

import Control.Concurrent.Chan.Unagi (OutChan, dupChan, newChan, writeChan)
import Control.Concurrent.Chan.Unagi.Bounded qualified as B
import Control.Concurrent.STM (modifyTVar', newTVar, readTVar)
import Control.Exception (catch, throwIO)
import Control.Monad (forever)
import Control.Monad.STM (atomically)
import Reacthome.Relay (LazyRaw, Uid)
import Reacthome.Relay.Error (RelayError (..), logError)
import Reacthome.Relay.Message (getMessageDestination)
import StmContainers.Map (delete, insert, lookup, newIO)
import Prelude hiding (lookup, show)

data RelayDispatcher = RelayDispatcher
    { sendMessage :: LazyRaw -> IO ()
    , getSource :: Uid -> IO (Source, IO ())
    , run :: IO ()
    }

type Source = OutChan LazyRaw

makeRelayDispatcher :: Int -> IO RelayDispatcher
makeRelayDispatcher bound = do
    (inChan, outChan) <- B.newChan bound
    sources <- newIO

    let
        sendMessage = B.writeChan inChan

        getSource uid = do
            (newInChan, _) <- newChan
            (broadcast, free) <- atomically do
                found <- lookup uid sources
                case found of
                    Nothing -> do
                        alive <- newTVar @Int 0
                        let
                            free = do
                                atomically do
                                    count <- readTVar alive
                                    if count > 0
                                        then modifyTVar' alive \a -> a - 1
                                        else delete uid sources
                                print $ "Close broadcast channel: " <> uid
                            lock = modifyTVar' alive (+ 1)
                        insert (newInChan, free, lock) uid sources
                        pure (newInChan, free)
                    Just (oldInChan, free, lock) -> do
                        lock
                        pure (oldInChan, free)
            source <- dupChan broadcast
            pure (source, free)

        getSink uid = do
            found <- atomically $ lookup uid sources
            case found of
                Nothing -> throwIO $ NoPeersFound uid
                Just (source, _, _) -> pure source

        run = forever do
            catch @RelayError
                do
                    message <- B.readChan outChan
                    let destination = getMessageDestination message
                    source <- getSink destination
                    writeChan source message
                logError

    pure RelayDispatcher{..}
