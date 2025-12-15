module Rest
    ( Request (..)
    , Response
    , BodyParams (..)
    , rest
    ) where

import Control.Exception (try)
import Control.Monad (join)
import Data.ByteString (ByteString)
import Data.ByteString.Lazy qualified as Lazy
import Network.HTTP.Types.Header (HeaderName, RequestHeaders, hContentType, hCookie)
import Network.HTTP.Types.Method (Method)
import Network.Wai qualified as W
import Network.Wai.Parse (Param, RequestParseException, lbsBackEnd, parseRequestBody)
import Rest.ContentType (ContentType)
import Web.Cookie (Cookies, parseCookies)

type Response = W.Response

data Request
    = Request
    { method :: Method
    , body :: IO Lazy.ByteString
    , bodyParams :: IO (Either String BodyParams)
    , headers :: RequestHeaders
    , header :: HeaderName -> Maybe ByteString
    , query :: ByteString -> Maybe ByteString
    , hasContentType :: ContentType -> Bool
    , cookies :: Maybe Cookies
    , cookie :: ByteString -> Maybe ByteString
    }

data BodyParams = BodyParams
    { lookup :: ByteString -> Either String ByteString
    , list :: [Param]
    }

rest :: W.Request -> Request
rest request =
    let
        method = request.requestMethod
        body = W.lazyRequestBody request
        bodyParams =
            try @RequestParseException
                (parseRequestBody lbsBackEnd request)
                >>= \case
                    Left e -> pure . Left $ show e
                    Right r -> do
                        let list = fst r

                        let lookup' name = do
                                case Prelude.lookup name list of
                                    Nothing -> Left $ "Missing `" <> show name <> "` parameter"
                                    Just param -> Right param

                        pure . Right $
                            BodyParams lookup' list

        headers = request.requestHeaders
        header name = Prelude.lookup name headers
        query name = join $ Prelude.lookup name request.queryString
        hasContentType contentType = Just contentType == header hContentType
        cookies = parseCookies <$> header hCookie
        cookie name = Prelude.lookup name =<< cookies
     in
        Request{..}
