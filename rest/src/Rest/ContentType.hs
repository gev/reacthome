module Rest.ContentType
    ( ContentType
    , ctTextPlane
    , ctApplicationJson
    , ctApplicationHtml
    ) where

import Data.ByteString (ByteString)

type ContentType = ByteString

ctTextPlane :: ContentType
ctTextPlane = "text/plain"

ctApplicationJson :: ContentType
ctApplicationJson = "application/json"

ctApplicationHtml :: ContentType
ctApplicationHtml = "text/html"
