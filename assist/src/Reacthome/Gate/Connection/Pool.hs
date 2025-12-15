module Reacthome.Gate.Connection.Pool
    ( GateConnectionPool (..)
    , makeConnectionPool
    ) where

import Control.Concurrent (newMVar)
import Data.HashMap.Strict (delete, empty, insert, lookup)
import Data.Text.Lazy (Text)
import Data.UUID (UUID)
import Reacthome.Assist.Environment (Environment)
import Reacthome.Gate.Connection (GateConnection, makeConnection)
import Util.MVar (runModify, runRead)
import Prelude hiding (lookup)

newtype GateConnectionPool = GateConnectionPool
    { getConnection :: UUID -> IO GateConnection
    }

makeConnectionPool ::
    (?environment :: Environment) =>
    (Text -> IO ()) ->
    IO GateConnectionPool
makeConnectionPool onMessage = do
    pool <- newMVar empty

    let connect uid = do
            let onError e = do
                    print e
                    runModify pool $ delete uid
            connection <- makeConnection uid onMessage onError
            runModify pool $ insert uid connection
            pure connection

    let getConnection uid =
            maybe (connect uid) pure
                =<< runRead pool (lookup uid)

    pure $
        GateConnectionPool
            { getConnection
            }
