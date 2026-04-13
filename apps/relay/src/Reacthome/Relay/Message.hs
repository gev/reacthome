module Reacthome.Relay.Message where

import Data.ByteString qualified as S
import Reacthome.Relay (StrictRaw, Uid)
import Prelude hiding (concat, length, splitAt, tail, take)

data RelayMessage = RelayMessage
    { header :: !RelayMessageHeader
    , content :: !StrictRaw
    }

data RelayMessageHeader = RelayMessageHeader
    { to :: !Uid
    , from :: !Uid
    }

serializeMessage :: RelayMessage -> StrictRaw
serializeMessage message =
    S.concat
        [ message.header.to
        , message.header.from
        , message.content
        ]
{-# INLINEABLE serializeMessage #-}

getMessageDestination :: StrictRaw -> Uid
getMessageDestination = S.take 16
{-# INLINEABLE getMessageDestination #-}

getMessageSource :: StrictRaw -> Uid
getMessageSource = S.drop 16 . S.take 32
{-# INLINEABLE getMessageSource #-}

getMessageHeader :: StrictRaw -> RelayMessageHeader
getMessageHeader raw =
    let
        (to, from) = S.splitAt 16 . S.take 32 $ raw
     in
        RelayMessageHeader{..}
{-# INLINEABLE getMessageHeader #-}

isMessageValid :: StrictRaw -> Bool
isMessageValid = (> 32) . S.length
{-# INLINEABLE isMessageValid #-}
