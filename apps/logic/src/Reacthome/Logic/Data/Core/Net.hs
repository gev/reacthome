module Reacthome.Logic.Data.Core.Net where

import Data.Set (Set)
import Data.Text (Text)
import Data.UUID (UUID)
import Data.UUID.V4 (nextRandom)
import Reacthome.Logic.Data.Core.Device

newtype NetId = NetId UUID

newtype NetCode = NetCode Text

data GlobalConnector = GlobalConnector
    { device :: Device
    , connector :: Connector
    }

data Net = Net
    { uid :: NetId
    , code :: NetCode
    , connectors :: Set GlobalConnector
    }

mkNetId :: IO NetId
mkNetId = NetId <$> nextRandom
