module JOSE.Util
    ( aesonOptions
    ) where

import Data.Aeson (Options (..), defaultOptions)

aesonOptions :: Options
aesonOptions =
    defaultOptions
        { tagSingleConstructors = True
        }
