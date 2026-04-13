module Reacthome.Logic.App where

import Reacthome.Logic.Server (LogicServer (..))
import WebSockets.Server (WebSocketServerApplication)
import Prelude hiding (length, splitAt, tail)

application :: LogicServer -> WebSocketServerApplication
application server = server.accept
