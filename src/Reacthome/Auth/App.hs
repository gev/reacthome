module Reacthome.Auth.App where

import Control.Monad.IO.Class
import Control.Monad.Trans.Except
import Data.String
import Lucid
import Network.Wai
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
import Web.Twain

app ::
    ( ?environment :: Environment
    , ?challenges :: Challenges
    , ?users :: Users
    , ?publicKeys :: PublicKeys
    ) =>
    Application
app = foldr ($) (notFound missing) router

router ::
    ( ?environment :: Environment
    , ?challenges :: Challenges
    , ?users :: Users
    , ?publicKeys :: PublicKeys
    ) =>
    [Middleware]
router =
    staticPolicy (addBase "public")
        : [ get "/" $ html' authentication
          , get "/register" $ html' registration
          , post "/authentication/begin" $ json' beginAuthentication
          , post "/authentication/complete" $ json' completeAuthentication
          , post "/registration/begin" do json' beginRegistration
          , post "/registration/complete" $ json' completeRegistration
          ]
  where
    html' = send . html . renderBS
    json' action = do
        res <- liftIO . runExceptT . action =<< fromBody
        send $ either (status status400 . text . fromString) json res

missing :: ResponderM a
missing = send $ html "Not found"
