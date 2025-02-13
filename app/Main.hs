import Reacthome.Auth.App
import Reacthome.Auth.Environment
import Reacthome.Auth.Repository.InMemory.Challenges
import Reacthome.Auth.Repository.InMemory.Credential.PublicKeys
import Reacthome.Auth.Repository.InMemory.Users
import Web.Scotty

main :: IO ()
main = do
  let ?environment =
        Environment
          { name = "Reacthome Auth Service"
          , domain = "reacthome.net"
          , timeout = 60_000
          , challengeSize = 20
          }
  challenges <- makeChallenges
  users <- makeUsers
  publicKeys <- makePublicKeys
  let ?challenges = challenges
  let ?users = users
  let ?publicKeys = publicKeys
  scotty 3000 app
