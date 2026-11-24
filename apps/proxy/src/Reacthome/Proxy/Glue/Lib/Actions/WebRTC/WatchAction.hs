module Reacthome.Proxy.Glue.Lib.Actions.WebRTC.WatchAction where

import Control.Monad (void)
import Glue.Eval (Eval (..), liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Reacthome.Proxy.Bridge.Downstream (Downstream (..))
import Reacthome.Proxy.Daemon.Actions.Encode qualified as E

webrtcWatchAction :: (?downstream :: Downstream) => IR Eval
webrtcWatchAction = NativeFunc webrtcWatchActionImpl

webrtcWatchActionImpl ::
    (?downstream :: Downstream) =>
    IR Eval -> Eval (IR Eval)
webrtcWatchActionImpl = \case
    String url -> do
        void . liftIO $ ?downstream.send $ E.watchAction url
        pure Void
    _ -> throwError $ wrongArgumentType ["String `url` required"]
