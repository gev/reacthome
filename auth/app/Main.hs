import Network.Wai.Handler.Warp (run)
import Network.Wai.Middleware.Static (addBase, staticPolicy)
import Reacthome.Auth.App (app)
import Reacthome.Auth.Environment (Environment (..))
import Reacthome.Auth.Repository.AuthFlows (makeAuthFlows)
import Reacthome.Auth.Repository.AuthUsers (makeAuthUsers)
import Reacthome.Auth.Repository.Clients (makeClients)
import Reacthome.Auth.Repository.Credentials.PublicKeys.SQLite qualified as U
import Reacthome.Auth.Repository.PublicKeys.SQLite qualified as J
import Reacthome.Auth.Repository.RefreshTokens.SQLite (makeRefreshTokens)
import Reacthome.Auth.Repository.Users.SQLite (makeUsers)
import Reacthome.Auth.Service.Secret (makeSecret)
import Util.SQLite (makePool)

main :: IO ()
main = do
    let port = 3002
    let ?environment =
            Environment
                { name = "Reacthome Auth Service"
                , domain = "reacthome.net"
                , appleApps = ["Q8QP3DQFJY.net.reacthome.studio"]
                , challengeSize = 20
                , authTimeout = 100
                , authFlowCookieTTL = 300
                , authCodeTTL = 30
                , accessTokenTTL = 900
                }
    authFlows <- makeAuthFlows
    let ?authFlows = authFlows
    authUsers <- makeAuthUsers
    let ?authUsers = authUsers
    authStore <- makePool "./var/db/auth.db" 100 10
    keyStore <- makePool "./var/db/keys.db" 100 10
    clients <- makeClients "./var/clients.json"
    let ?clients = clients
    users <- makeUsers authStore
    let ?users = users
    userPublicKeys <- U.makePublicKeys authStore
    let ?userPublicKeys = userPublicKeys
    jwkPublicKeys <- J.makePublicKeys keyStore
    let ?jwkPublicKeys = jwkPublicKeys
    keyPair <- makeSecret
    let ?keyPair = keyPair
    refreshTokens <- makeRefreshTokens authStore
    let ?refreshTokens = refreshTokens
    putStrLn $ "Serving Reacthome Auth on port " <> show port
    run port $
        staticPolicy
            (addBase "auth/public")
            app
