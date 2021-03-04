module Fest.Interaksjon exposing (..)

import Fest.CS exposing (CS)
import Fest.CV exposing (CV)
import Json.Decode as D exposing (Decoder)


type Id
    = Id String


type alias Relevans =
    Fest.CS.CS


type alias Interaksjon =
    { id : Id
    , relevans : Relevans
    , situasjonskriterium : Maybe String
    , kliniskKonsekvens : String
    , interaksjonsmekanisme : Maybe String
    }


decode =
    D.map5 Interaksjon
        (D.map Id (D.field "id" D.string))
        (D.field "relevans" Fest.CS.decode)
        (D.maybe (D.field "situasjonskriterium" D.string))
        (D.field "kliniskKonsekvens" D.string)
        (D.maybe (D.field "interaksjonsmekanisme" D.string))
