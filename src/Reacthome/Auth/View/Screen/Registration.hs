{-# LANGUAGE QualifiedDo #-}
{-# LANGUAGE RebindableSyntax #-}
{-# LANGUAGE NoOverloadedStrings #-}
{-# OPTIONS_GHC -Wno-unused-do-bind #-}

module Reacthome.Auth.View.Screen.Registration where

import Data.ByteString.Lazy
import Html
import Html.QualifiedDo qualified as H

registration :: ByteString
registration =
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
            Body :@ OnloadA "init(register)" :> H.do
                Div :> H.do
                    Img :@ (WidthA "150px" # SrcA "/icon.png" # AltA "Reacthome logo")
                    H2 :> "Reacthome"
                    H1 :> "Registration"
                Form :@ IdA "form" :> H.do
                    Div :> H.do
                        Input :@ (NameA "login" # TypeA "text" # PlaceholderA "Login" # AutocompleteA "on" # AutofocusA)
                    Div :> H.do
                        Input :@ (NameA "name" # TypeA "text" # PlaceholderA "Name" # AutocompleteA "on")
                    Div :> H.do
                        Button :@ TypeA "submit" :> "Sign up"
                        A :@ HrefA "/" :> "Sign in"
                Div :@ IdA "debug"
