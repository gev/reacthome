module Util.Aeson
    ( omitNothing
    , typeFieldLabelModifier
    ) where

import Data.Aeson (Options (..), defaultOptions)

omitNothing :: Options
omitNothing =
    defaultOptions
        { omitNothingFields = True
        }

typeFieldLabelModifier :: Options
typeFieldLabelModifier =
    defaultOptions
        { fieldLabelModifier = \s ->
            if s == "type'"
                then "type"
                else s
        }
