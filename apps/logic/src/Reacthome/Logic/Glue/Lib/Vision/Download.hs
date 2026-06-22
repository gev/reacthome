module Reacthome.Logic.Glue.Lib.Vision.Download where

import Control.Concurrent (forkIO)
import Control.Monad (void)
import Data.ByteString qualified as S
import Data.ByteString.Builder qualified as B
import Data.ByteString.Lazy qualified as L
import Data.Foldable (traverse_)
import Data.Text (Text)
import Data.Text qualified as T
import Data.Text.Encoding qualified as T
import Glue.Eval (Eval, liftIO, throwError)
import Glue.Eval.Exception (wrongArgumentType)
import Glue.IR (IR (..))
import Reacthome.Logic.Glue.Sink (Sink)
import System.Directory (doesFileExist, getFileSize)

downloadAsset ::
    (?sink :: Sink) =>
    IR Eval
downloadAsset = Special downloadAssetImpl

downloadAssetImpl ::
    (?sink :: Sink) =>
    [IR Eval] -> Eval (IR Eval)
downloadAssetImpl [Symbol key] = do
    liftIO $ sendAsset [key]
    pure Void
downloadAssetImpl [DottedSymbol key] = do
    liftIO $ sendAsset key
    pure Void
downloadAssetImpl _ =
    throwError $
        wrongArgumentType
            ["Name parameter should be `Symbol` or `DottedSymbol`"]

sendAsset :: (?sink :: Sink) => [Text] -> IO ()
sendAsset parts = do
    fileExists <- doesFileExist assetPath
    if not fileExists
        then putStrLn $ "Asset not found: " <> assetPath
        else void $ forkIO do
            assetSize <- getFileSize assetPath
            assetChunks <- L.toChunks <$> L.readFile assetPath
            let offsets = scanl nextOffset 0 assetChunks
            let chunks = zipWith (makeChunk assetSize) assetChunks offsets
            traverse_ ?sink chunks
  where
    makeChunk fileSize chunk offset =
        B.toLazyByteString $
            B.word8 2
                <> B.word64BE (fromIntegral fileSize)
                <> B.word32BE (fromIntegral $ S.length chunk)
                <> B.word64BE (fromIntegral offset)
                <> B.byteString (T.encodeUtf8 assetName)
                <> B.byteString chunk

    nextOffset acc chunk = acc + S.length chunk

    assetName = T.intercalate "." parts
    assetPath = T.unpack $ "./assets/" <> assetName
