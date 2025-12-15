module Reacthome.Gate.Connection
    ( GateConnection (..)
    , makeConnection
    ) where

import Control.Concurrent (forkFinally)
import Control.Concurrent.Async (concurrently_)
import Control.Concurrent.STM (TBQueue, atomically, newTBQueueIO, readTBQueue, writeTBQueue)
import Control.Exception (SomeException)
import Control.Monad (forever, void)
import Data.Text.Lazy (Text)
import Data.UUID (UUID, toString)
import Network.HTTP.Types (HeaderName)
import Network.WebSockets (ClientApp, Connection, defaultConnectionOptions, receiveData, sendTextData)
import Reacthome.Assist.Environment (Environment (..), GateConfig (..))
import Wuss (runSecureClientWith)

newtype GateConnection = GateConnection
    { send :: Text -> IO ()
    }

makeConnection ::
    (?environment :: Environment) =>
    UUID ->
    (Text -> IO ()) ->
    (SomeException -> IO ()) ->
    IO GateConnection
makeConnection uid onMessage onError = do
    queue <- newTBQueueIO $ fromIntegral ?environment.queueSize
    void $
        forkFinally
            ( connect uid $
                run queue onMessage
            )
            (either onError pure)
    pure
        GateConnection
            { send = atomically . writeTBQueue queue
            }

run ::
    TBQueue Text ->
    (Text -> IO ()) ->
    Connection ->
    IO ()
run queue onMessage connection =
    concurrently_
        (forever $ onMessage =<< receiveData connection)
        (forever $ sendTextData connection =<< atomically (readTBQueue queue))

connect ::
    (?environment :: Environment) =>
    UUID ->
    ClientApp a ->
    IO a
connect uid =
    runSecureClientWith
        ?environment.gate.host
        ?environment.gate.port
        ("/" <> toString uid)
        defaultConnectionOptions
        [(hSecWebSocketProtocol, ?environment.gate.protocol)]

hSecWebSocketProtocol :: HeaderName
hSecWebSocketProtocol = "Sec-WebSocket-Protocol"
