module Fest.Atc exposing (..)

import Json.Decode as D
import List.Extra exposing (group)


type AtcCode
    = AtcCode String


type alias Atc =
    { v : AtcCode
    , s : String
    , descriptiveName : String
    }


asString : AtcCode -> String
asString (AtcCode s) =
    s


toFormattedString : AtcCode -> String
toFormattedString (AtcCode atcCodeString) =
    let
        group =
            String.left 4 atcCodeString

        cat =
            String.dropLeft 4 atcCodeString
    in
    if cat == "" then
        group

    else
        group ++ "\u{00A0}" ++ cat



--        <Atc V="R06AE07" S="2.16.578.1.12.4.1.1.7180" DN="Cetirizin" />


decode : D.Decoder Atc
decode =
    D.map3 Atc
        (D.map AtcCode (D.field "v" D.string))
        (D.field "s" D.string)
        (D.field "dn" D.string)
