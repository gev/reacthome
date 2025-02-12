module Reacthome.Auth.View.Screen.Authentication where

import Text.Blaze.Html
import Text.Blaze.Html5 qualified as H
import Text.Blaze.Html5.Attributes qualified as A

authentication :: Html
authentication =
    H.docTypeHtml do
        H.head do
            H.title "Reacthome. Registration"
            H.meta ! A.charset "utf-8"
            H.meta ! A.name "description" ! A.content "Reacthome Auth Service"
            H.meta ! A.name "viewport" ! A.content "width=device-width, initial-scale=1.0"
            H.link ! A.rel "icon" ! A.type_ "image/png" ! A.href "/icon.png"
            H.link ! A.rel "stylesheet" ! A.href "/styles.css"
            H.script ! A.src "/auth.js" $ mempty
        H.body ! A.onload "init(register)" $ do
            H.div do
                H.img ! A.width "150px" ! A.src "/icon.png" ! A.alt "Reacthome logo"
                H.h2 "Reacthome"
                H.h1 "Registration"
            H.form ! A.id "form" $ do
                H.div do
                    H.input ! A.name "login" ! A.type_ "text" ! A.placeholder "Login" ! A.autocomplete "on" ! A.autofocus mempty
                H.div do
                    H.button ! A.type_ "submit" $ "Sign up"
                    H.a ! A.href "/" $ "Sign in"
            H.div ! A.id "debug" $ mempty
