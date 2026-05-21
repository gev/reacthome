module Reacthome.Logic.Glue.Publisher where

import Data.ByteString.Lazy qualified as L
import Data.Text (Text, unpack)

-- import Data.Text.Encoding (encodeUtf8)

import Control.Exception (SomeException, catch)
import Reacthome.Logic.PubSub.Publisher (Publisher, makePublisher)

type GluePublisher = Publisher Text Text L.ByteString

makeGluePublisher :: IO GluePublisher
makeGluePublisher = do
    makePublisher get send
  where
    get key = catch @SomeException
        do
            let file = "./apps/logic/glue/" <> unpack key <> ".glue"
            glue <- L.readFile file
            pure $ Just glue
        \err -> do
            print err
            pure Nothing

    send = undefined

--   ?sink $ "(put store.tmp \"" <> enc key <> "\" " <> glue <> ")"
-- where
--   enc = L.fromStrict . encodeUtf8
