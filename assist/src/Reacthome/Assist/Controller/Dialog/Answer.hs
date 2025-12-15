module Reacthome.Assist.Controller.Dialog.Answer
    ( handleAnswer
    ) where

import Data.Aeson (eitherDecode)
import Data.Text.Lazy (Text)
import Reacthome.Assist.Dialog.Gate (setAnswer)
import Reacthome.Assist.Service.Dialog (Answers, unpack)
import Util.Encoding.Utf8.Lazy (encodeUtf8)

handleAnswer ::
    (?answers :: Answers) =>
    Text ->
    IO ()
handleAnswer message =
    either
        (const $ pure ()) -- print
        (uncurry setAnswer)
        (unpack =<< eitherDecode (encodeUtf8 message))
