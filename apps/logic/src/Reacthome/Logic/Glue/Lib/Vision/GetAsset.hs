module Reacthome.Logic.Glue.Lib.Vision.GetAsset where

import Control.Concurrent (forkIO)
import Control.Monad (void, zipWithM_)
import Data.ByteString qualified as S
import Data.ByteString.Builder qualified as B
import Data.ByteString.Lazy qualified as L
import Data.Text (Text)
import Data.Text qualified as T
import Data.Text.Encoding qualified as T
import Glue.Eval (Eval, liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Reacthome.Logic.Glue.Sink (Sink)
import System.Directory (doesFileExist, getFileSize)

getAsset ::
    (?sink :: Sink) =>
    IR Eval
getAsset = Special getAssetImpl

getAssetImpl ::
    (?sink :: Sink) =>
    [IR Eval] -> Eval (IR Eval)
getAssetImpl [Symbol key] = do
    liftIO $ sendAsset [key]
    pure Void
getAssetImpl [DottedSymbol key] = do
    liftIO $ sendAsset key
    pure Void
getAssetImpl _ =
    throwError $
        wrongArgumentType
            ["Name parameter should be `Symbol` or `DottedSymbol`"]

sendAsset :: (?sink :: Sink) => [Text] -> IO ()
sendAsset parts = do
    let name = T.intercalate "." parts
    let path = T.unpack $ "./assets/" <> name
    fileExists <- doesFileExist path
    if not fileExists
        then putStrLn $ "Asset not found: " <> path
        else void $ forkIO do
            fileSize <- getFileSize path
            chunks <- L.toChunks <$> L.readFile path
            zipWithM_ (sendChunk name fileSize $ length chunks) chunks [0 ..]

sendChunk :: (?sink :: Sink) => Text -> Integer -> Int -> S.ByteString -> Int -> IO ()
sendChunk name fileSize total chunk index = do
    let builder =
            B.word8 2
                <> B.word64BE (fromIntegral fileSize)
                <> B.word32BE (fromIntegral total)
                <> B.word32BE (fromIntegral $ S.length chunk)
                <> B.word32BE (fromIntegral index)
                <> B.byteString (T.encodeUtf8 name)
                <> B.byteString chunk
    ?sink $ B.toLazyByteString builder
