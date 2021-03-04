module Fest.CSTests exposing (..)

import Expect
import Fest.CS exposing (CS)
import Json.Decode as D
import Test exposing (..)


suite : Test
suite =
    describe "The CS File"
        [ describe "decode"
            [ test "Decodes Valid Json" <|
                \_ ->
                    let
                        json =
                            """{ "v": "1", "dn": "Apotek" }"""

                        decodedOutput =
                            D.decodeString Fest.CS.decode json
                    in
                    Expect.equal
                        decodedOutput
                        (Ok
                            { v = "1", dn = "Apotek" }
                        )
            ]
        ]
