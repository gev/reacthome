module Reacthome.Relay.Message where

import Data.ByteString qualified as S
import Data.ByteString.Lazy qualified as L
import Reacthome.Relay (LazyRaw, StrictRaw, Uid)
import Prelude hiding (concat, length, splitAt, tail, take)

data RelayMessage = RelayMessage
    { header :: !RelayMessageHeader
    , content :: !LazyRaw
    }
    deriving (Show)

data RelayMessageHeader = RelayMessageHeader
    { from :: !Uid
    , to :: !Uid
    }
    deriving (Show)

serializeMessage :: RelayMessage -> LazyRaw
serializeMessage message =
    L.concat
        [ L.fromStrict message.header.to
        , L.fromStrict message.header.from
        , message.content
        ]
{-# INLINEABLE serializeMessage #-}

getMessageDestination :: LazyRaw -> Uid
getMessageDestination = L.toStrict . L.drop 16 . L.take 32
{-# INLINEABLE getMessageDestination #-}

getMessageSource :: StrictRaw -> Uid
getMessageSource = S.take 16
{-# INLINEABLE getMessageSource #-}

getMessageHeader :: LazyRaw -> RelayMessageHeader
getMessageHeader raw =
    let
        (from, to) = S.splitAt 16 . L.toStrict . L.take 32 $ raw
     in
        RelayMessageHeader{..}
{-# INLINEABLE getMessageHeader #-}

isMessageValid :: LazyRaw -> Bool
isMessageValid = (> 32) . L.length
{-# INLINEABLE isMessageValid #-}
