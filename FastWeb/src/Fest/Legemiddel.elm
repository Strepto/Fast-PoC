module Fest.Legemiddel exposing (Legemiddel, decode)

import Fest.Atc exposing (Atc)
import Json.Decode as D


type alias Legemiddel =
    { --varenavn : String
      maybeAtc : Maybe Atc
    , navnFormStyrke : String
    }


decode : D.Decoder Legemiddel
decode =
    D.map2 Legemiddel
        --(D.field "varenavn" D.string)
        (D.maybe (D.field "atc" Fest.Atc.decode))
        (D.field "navnFormStyrke" D.string)
