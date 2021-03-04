module Fest.InteraksjonTests exposing (..)

import Expect
import Fest.CS exposing (CS)
import Fest.Interaksjon exposing (Interaksjon)
import Json.Decode as D
import Test exposing (..)


suite : Test
suite =
    describe "The Interaksjon File"
        [ describe "decode"
            [ test "Decodes Valid Json" <|
                \_ ->
                    let
                        json =
                            """{
    "id": "id",
    "relevans": {
      "v": "v",
      "dn": "dn"
    },
    "situasjonskriterium": "situasjonskriterium",
    "kliniskKonsekvens": "kliniskKonsekvens",
    "interaksjonsmekanisme": "interaksjonsmekanisme"
}"""

                        decodedOutput =
                            D.decodeString Fest.Interaksjon.decode json
                    in
                    Expect.equal
                        decodedOutput
                        (Ok
                            (Interaksjon
                                { id = "id", relevans = { v = "v", dn = "dn" }, situasjonskriterium = Just "situasjonskriterium", kliniskKonsekvens = Just "kliniskKonsekvens", interaksjonsmekanisme = "interaksjonsmekanisme" }
                            )
                        )
            ]
        ]
