module Reacthome.Core.Site where

import Data.Set (Set, insert)
import Data.Text (Text)
import Data.UUID (UUID)

newtype SiteId = SiteId UUID
    deriving (Eq, Ord, Show)

newtype SiteCode = SiteCode Text

data Site = Site
    { uid :: SiteId
    , code :: SiteCode
    , sites :: Set SiteId
    }

addSite :: SiteId -> Site -> Site
addSite uid site = site{sites = insert uid site.sites}
