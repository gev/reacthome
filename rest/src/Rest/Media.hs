module Rest.Media
    ( toHTML
    , toJSON
    , fromJSON
    ) where

import Data.Aeson (FromJSON, ToJSON, eitherDecode, encode)
import Lucid (Html, renderBS)
import Rest (Request (..), Response)
import Rest.ContentType (ctApplicationHtml, ctApplicationJson)
import Rest.Status (ok)

toHTML :: (Applicative a) => Html h -> a Response
toHTML = ok ctApplicationHtml mempty . renderBS

toJSON :: (ToJSON t, Applicative a) => t -> a Response
toJSON = ok ctApplicationJson mempty . encode

fromJSON :: (FromJSON t) => Request -> IO (Either String t)
fromJSON request =
    if request.hasContentType ctApplicationJson
        then eitherDecode <$> request.body
        else pure $ Left "Request should have `application/json` content type"
