module Fest.CS exposing (..)

import Json.Decode as Decode


type alias CS =
    { v : String
    , dn : String
    }


decode : Decode.Decoder CS
decode =
    Decode.map2 CS
        (Decode.field "v" Decode.string)
        (Decode.field "dn" Decode.string)
