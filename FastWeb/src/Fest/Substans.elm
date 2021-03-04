module Fest.Substans exposing (..)

import Fest.Atc exposing (Atc)
import Json.Decode as D


type alias Substans =
    { maybeAtc : Maybe Atc
    , substans : String
    , maybeRefVirkestoff : Maybe (List String)
    }


decode : D.Decoder Substans
decode =
    D.map3 Substans
        (D.maybe (D.field "atc" Fest.Atc.decode))
        (D.field "substans" D.string)
        (D.maybe (D.list (D.field "refVirkestoff" D.string)))
