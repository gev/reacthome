module Reacthome.Relay.App
    ( application
    ) where

import Control.Error (exceptT)
import Control.Monad (when)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Except (except)
import Data.Text (length, tail)
import Reacthome.Relay.Error (RelayError (..), logError)
import Reacthome.Relay.Server (RelayServer (..))
import Util.Encoding.UUID (fromText)
import Util.Encoding.Utf8 (decodeUtf8)
import WebSockets.PendingConnection (WebSocketPendingConnection (..))
import WebSockets.Server (WebSocketServerApplication)
import Prelude hiding (length, splitAt, tail)

application :: RelayServer -> WebSocketServerApplication
application server pending = exceptT (logError . InvalidPeer) pure do
    path <- except (decodeUtf8 pending.path)
    when (length path > 1) do
        let origin = tail path
        peer <- except (fromText origin)
        lift (server.accept pending peer)
