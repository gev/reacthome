module Reacthome.Assist.Controller.Dialog.Query
    ( sendQuery
    ) where

import Data.Aeson (encode)
import Data.Bifunctor (first)
import Reacthome.Assist.Domain.Query (Query)
import Reacthome.Assist.Domain.Server.Id (ServerId (..))
import Reacthome.Assist.Service.Dialog (Container)
import Reacthome.Gate.Connection (GateConnection (..))
import Reacthome.Gate.Connection.Pool (GateConnectionPool (..))
import Util.Encoding.Utf8.Lazy (decodeUtf8)

sendQuery ::
    (?gateConnectionPool :: GateConnectionPool) =>
    ServerId ->
    Container Query ->
    IO ()
sendQuery sid query = do
    gate <- ?gateConnectionPool.getConnection sid.value
    either
        do print
        do gate.send
        do first show (decodeUtf8 . encode $ query)
