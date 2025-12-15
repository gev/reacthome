module Rest.Method
    ( get
    , post
    , match
    ) where

import Network.HTTP.Types (Method, methodGet, methodPost)
import Rest (Request (..), Response)
import Rest.Status (notAllowed)

type Handler m =
    (?request :: Request) =>
    (Monad m) =>
    m Response ->
    m Response

get :: Handler m
get = match methodGet

post :: Handler m
post = match methodPost

match :: Method -> Handler m
match method controller =
    if ?request.method == method
        then controller
        else notAllowed method
