{-# LANGUAGE QualifiedDo #-}
{-# LANGUAGE RebindableSyntax #-}
{-# LANGUAGE NoOverloadedStrings #-}
{-# OPTIONS_GHC -Wno-unused-do-bind #-}

module Reacthome.Auth.View.Screen.Authentication where

import Data.ByteString.Lazy
import Html
import Html.QualifiedDo qualified as H

authentication :: ByteString
authentication =
    renderByteString H.do
        DOCTYPE
        Html :> H.do
            Head :> H.do
                Title :> "Reacthome. Registration"
                Meta :@ (NameA "charset" # ContentA "utf-8")
                Meta :@ (NameA "description" # ContentA "Reacthome Auth Service")
                Meta :@ (NameA "viewport" # ContentA "width=device-width, initial-scale=1.0")
                Link :@ (RelA "icon" # TypeA "image/png" # HrefA "/icon.png")
                Link :@ (RelA "stylesheet" # HrefA "/styles.css")
                Script :@ SrcA "/auth.js"
            Body :@ OnloadA "init(authenticate)" :> H.do
                Div :> H.do
                    Img :@ (WidthA "150px" # SrcA "/icon.png" # AltA "Reacthome logo")
                    H2 :> "Reacthome"
                    H1 :> "Registration"
                Form :@ IdA "form" :> H.do
                    Div :> H.do
                        Input :@ (NameA "login" # TypeA "text" # PlaceholderA "Login" # AutocompleteA "on" # AutofocusA)
                    Div :> H.do
                        Button :@ TypeA "submit" :> "Sign up"
                        A :@ HrefA "/register" :> "Sign in"
                Div :@ IdA "debug"
