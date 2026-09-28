{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module Reacthome.Proxy.Glue.Lib.Config.App (
    appConfig,
) where

import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Text (Text)
import Data.Text qualified as T
import Glue.Eval (Eval, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..), hostValue)
import Reacthome.Proxy.Config.App (
    AppConfig (..),
    AssetsConfig (..),
    ClientConfig (..),
    DiscoveryConfig (..),
    ProxyConfig (..),
 )

appConfig :: IR Eval
appConfig = NativeFunc appConfigImpl

appConfigImpl :: IR Eval -> Eval (IR Eval)
appConfigImpl = \case
    Object m -> do
        config <- parseAppConfig [] m
        pure $ NativeValue (hostValue config)
    _ -> err [] "Expected Object argument in `app`"

parseAppConfig :: [Text] -> Map Text (IR Eval) -> Eval AppConfig
parseAppConfig path m = do
    proxy <- field path "proxy" parseProxyConfig m
    daemon <- field path "daemon" parseClientConfig m
    relay <- field path "relay" parseClientConfig m
    discovery <- field path "discovery" parseDiscoveryConfig m
    assets <- field path "assets" parseAssetsConfig m
    gluePath <- field path "glue-path" parseString m
    pure AppConfig{..}

parseProxyConfig :: [Text] -> IR Eval -> Eval ProxyConfig
parseProxyConfig = parseObject \p m -> do
    host <- field p "host" parseString m
    port <- field p "port" parseInt m
    daemon <- field p "daemon" parseString m
    pure ProxyConfig{..}

parseClientConfig :: [Text] -> IR Eval -> Eval ClientConfig
parseClientConfig = parseObject \p m -> do
    host <- field p "host" parseString m
    port <- field p "port" parseInt m
    uri <- field p "uri" parseString m
    pure ClientConfig{..}

parseAssetsConfig :: [Text] -> IR Eval -> Eval AssetsConfig
parseAssetsConfig = parseObject \p m -> do
    path <- field p "path" parseString m
    proxy <- field p "proxy" parseString m
    pure AssetsConfig{..}

parseDiscoveryConfig :: [Text] -> IR Eval -> Eval DiscoveryConfig
parseDiscoveryConfig = parseObject \p m -> do
    announceInterval <- field p "announce-interval" parseInt m
    announceGroup <- field p "announce-group" parseString m
    announcePort <- field p "announce-port" parseInt m
    probeGroup <- field p "probe-group" parseString m
    probePort <- field p "probe-port" parseInt m
    timeout <- field p "timeout" parseInt m
    pure DiscoveryConfig{..}

field ::
    [Text] ->
    Text ->
    ([Text] -> IR Eval -> Eval a) ->
    Map Text (IR Eval) ->
    Eval a
field path key parser m = do
    let fieldPath = path <> [key]
    case Map.lookup key m of
        Just val -> parser fieldPath val
        Nothing -> err fieldPath "Field is required"

parseObject ::
    ([Text] -> Map Text (IR Eval) -> Eval a) ->
    [Text] ->
    IR Eval ->
    Eval a
parseObject f path = \case
    Object innerMap -> f path innerMap
    got -> err path $ "Expected Object, got " <> T.pack (show got)

parseString :: [Text] -> IR Eval -> Eval String
parseString path = \case
    String s -> pure $ T.unpack s
    Symbol s -> pure $ T.unpack s
    got -> err path $ "Expected String, got " <> T.pack (show got)

parseInt :: [Text] -> IR Eval -> Eval Int
parseInt path = \case
    Integer n -> pure n
    got -> err path $ "Expected Integer, got " <> T.pack (show got)

err :: [Text] -> Text -> Eval a
err path msg =
    let pathStr = if null path then "" else "Field '" <> T.intercalate "." path <> "': "
     in throwError $ wrongArgumentType [pathStr <> msg]
