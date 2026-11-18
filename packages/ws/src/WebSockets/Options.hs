module WebSockets.Options where

data WebSocketOptions = WebSocketOptions
    { bound :: !Int
    , chunkSize :: !Int
    , delay :: !Int
    }

defaultWebSocketOptions :: WebSocketOptions
defaultWebSocketOptions =
    WebSocketOptions
        { bound = 10
        , chunkSize = 20
        , delay = 30
        }
