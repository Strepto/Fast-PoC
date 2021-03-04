module Fest.InteraksjonCouple exposing (..)

import Fest.Interaksjon exposing (Interaksjon)
import Fest.Substans exposing (Substans)
import Json.Decode as D


type alias InteraksjonCouple =
    { substansA : Substans
    , substansB : Substans
    , interaksjon : Interaksjon
    }


decode =
    D.map3 InteraksjonCouple
        (D.field "substansA" Fest.Substans.decode)
        (D.field "substansB" Fest.Substans.decode)
        (D.field "interaksjon" Fest.Interaksjon.decode)
