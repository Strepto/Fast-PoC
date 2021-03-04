module Fest.CV exposing (..)

import Json.Decode as D


type alias CV =
    { v : String
    , s : String
    , dn : String
    , ot : String
    }


decode : D.Decoder CV
decode =
    D.map4 CV
        (D.field "v" D.string)
        (D.field "s" D.string)
        (D.field "dn" D.string)
        (D.field "ot" D.string)
