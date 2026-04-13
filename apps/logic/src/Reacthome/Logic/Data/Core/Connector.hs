module Reacthome.Logic.Data.Core.Connector where

import Reacthome.Logic.Data.Core.Site (SiteId)

data ConnectorType
    = Electric Electric
    | RS485 RS485
    | Ethernet
    | Logic
    | Hydro Hydro
    | Pneuma
    | Geo Geo
    deriving (Eq, Ord, Show)

data Electric = AC Int | DC Int | N | PE
    deriving (Eq, Ord, Show)

data RS485 = A | B
    deriving (Eq, Ord, Show)

data Hydro = Cool | Hot
    deriving (Eq, Ord, Show)

data Geo = Site SiteId | Point Coord
    deriving (Eq, Ord, Show)

data Coord = Coord {x :: Double, y :: Double, z :: Double}
    deriving (Eq, Ord, Show)
