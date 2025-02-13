module Reacthome.Auth.App where

import Control.Monad.Trans.Class
import Control.Monad.Trans.Except
import Data.String
import Lucid
import Network.Wai.Middleware.Static
import Reacthome.Auth.Controller.Authentication.Begin
import Reacthome.Auth.Controller.Authentication.Complete
import Reacthome.Auth.Controller.Registration.Begin
import Reacthome.Auth.Controller.Registration.Complete
import Reacthome.Auth.Domain.Credential.PublicKeys
import Reacthome.Auth.Domain.Users
import Reacthome.Auth.Environment
import Reacthome.Auth.Service.Challenges (Challenges)
import Reacthome.Auth.View.Screen.Authentication
import Reacthome.Auth.View.Screen.Registration
import Web.Scotty

app ::
    ( ?environment :: Environment
    , ?challenges :: Challenges
    , ?users :: Users
    , ?publicKeys :: PublicKeys
    ) =>
    ScottyM ()
app = do
    middleware $ staticPolicy (addBase "public")
    router

router ::
    ( ?environment :: Environment
    , ?challenges :: Challenges
    , ?users :: Users
    , ?publicKeys :: PublicKeys
    ) =>
    ScottyM ()
router = do
    get "/" $ html' authentication
    get "/register" $ html' registration
    post "/authentication/begin" $ json' beginAuthentication
    post "/authentication/complete" $ json' completeAuthentication
    post "/registration/begin" $ json' beginRegistration
    post "/registration/complete" $ json' completeRegistration
  where
    html' = html . renderText
    json' action =
        either (text . fromString) json =<< lift . runExceptT . action =<< jsonData
