{-# LANGUAGE NoImplicitPrelude #-}

module Reacthome.Auth.View.Screen.Registration where

import Text.Blaze.Html5 as E
import Text.Blaze.Html5.Attributes as A
import Prelude (mempty, ($))

registration :: Html
registration =
    docTypeHtml do
        E.head do
            E.title "Reacthome. Registration"
            meta ! charset "utf-8"
            meta ! name "description" ! content "Reacthome Auth Service"
            meta ! name "viewport" ! content "width=device-width, initial-scale=1.0"
            link ! rel "icon" ! type_ "image/png" ! href "/icon.png"
            link ! rel "stylesheet" ! href "/styles.css"
            script ! src "/auth.js" $ mempty
        body ! onload "init(register)" $ do
            E.div do
                img ! width "150px" ! src "/icon.png" ! alt "Reacthome logo"
                h2 "Reacthome"
                h1 "Registration"
            E.form ! A.id "form" $ do
                div do
                    input ! name "login" ! type_ "text" ! placeholder "Login" ! autocomplete "on" ! autofocus mempty
                div do
                    input ! name "name" ! type_ "text" ! placeholder "Name" ! autocomplete "on"
                div do
                    button ! type_ "submit" $ "Sign up"
                    a ! href "/" $ "Sign in"
            div ! A.id "debug" $ mempty
