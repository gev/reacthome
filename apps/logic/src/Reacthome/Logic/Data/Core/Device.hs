module Reacthome.Logic.Data.Core.Device where

import Control.Monad (join)
import Data.Set (Set, fromList)
import Data.Text (Text)
import Data.UUID (UUID)
import Data.UUID.V4 (nextRandom)
import Reacthome.Logic.Data.Core.Connector (ConnectorType)

newtype DeviceId = DeviceId UUID
    deriving (Eq, Ord, Show)

newtype DeviceCode = DeviceCode Text
    deriving (Eq, Ord, Show)

newtype DeviceSpecId = DeviceSpecId Text
    deriving (Eq, Ord, Show)

data DeviceVersion = DeviceVersion
    { major :: Int
    , minor :: Int
    }
    deriving (Eq, Ord, Show)

data DeviceSpec = DeviceSpec
    { uid :: DeviceSpecId
    , version :: DeviceVersion
    , name :: Text
    , connectors :: [ConnectorSpec]
    }
    deriving (Eq, Ord, Show)

data Device = Device
    { uid :: DeviceId
    , code :: DeviceCode
    , name :: Text
    , spec :: DeviceSpec
    , connectors :: Set Connector
    }
    deriving (Eq, Ord, Show)

data Connector = Connector
    { spec :: ConnectorSpec
    , index :: Int
    }
    deriving (Eq, Ord, Show)

data ConnectorSpec = ConnectorSpec
    { typ :: ConnectorType
    , code :: Text
    , amount :: Int
    }
    deriving (Eq, Ord, Show)

mkDevice :: DeviceSpec -> DeviceId -> DeviceCode -> Text -> Device
mkDevice spec uid code name = Device{..}
  where
    connectors =
        fromList $
            join
                [ [ Connector spec' i
                  | i <- [1 .. spec'.amount]
                  ]
                | spec' <- spec.connectors
                ]

mkDeviceId :: IO DeviceId
mkDeviceId = DeviceId <$> nextRandom
