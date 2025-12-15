module Reacthome.Assist.App
    ( app
    ) where

import JOSE.PublicKey (PublicKeys)
import Network.Wai (Application, Request (..))
import Reacthome.Assist.Controller.Yandex (runDialog)
import Reacthome.Assist.Domain.Users (Users)
import Reacthome.Assist.Service.Dialog (Answers)
import Reacthome.Gate.Connection.Pool (GateConnectionPool)
import Rest (rest)
import Rest.Method (post)
import Rest.Status (notFound)

app ::
    ( ?answers :: Answers
    , ?gateConnectionPool :: GateConnectionPool
    , ?publicKeys :: PublicKeys IO
    , ?users :: Users
    ) =>
    Application
app request respond = do
    let ?request = rest request
    respond
        =<< case request.pathInfo of
            ["yandex"] -> post runDialog
            _ -> notFound
