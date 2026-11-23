module Reacthome.Proxy.Glue.Lib.Actions.WatchAction where

import Control.Monad (void)
import Glue.Eval (Eval (..), liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Reacthome.Proxy.Bridge.Downstream (Downstream (..))
import Reacthome.Proxy.Daemon.Actions.Encode qualified as E

watchAction :: (?downstream :: Downstream) => IR Eval
watchAction = NativeFunc watchActionImpl

watchActionImpl ::
    (?downstream :: Downstream) =>
    IR Eval -> Eval (IR Eval)
watchActionImpl = \case
    String url -> do
        void . liftIO $ ?downstream.send $ E.watchAction url
        pure Void
    _ -> throwError $ wrongArgumentType ["String `url` required"]
