module ElementExt exposing (arrowDownKeyCode, arrowUpKeyCode, backspaceKeyCode, enterKeyCode, onArrowDownWithPreventDefault, onArrowUpWithPreventDefault, onEnter, onKeysDown, onSubmit, onTabWithPreventDefault, tabKeyCode)

import Element
import Html
import Html.Events
import Json.Decode as Decode


onSubmit : msg -> Element.Attribute msg
onSubmit msg =
    Element.htmlAttribute
        (Html.Events.onSubmit msg)


{-| -}
onEnter : msg -> Element.Attribute msg
onEnter msg =
    Element.htmlAttribute
        (Html.Events.on "keyup"
            (Decode.field "key" Decode.string
                |> Decode.andThen
                    (\key ->
                        if key == "Enter" then
                            Decode.succeed msg

                        else
                            Decode.fail "Not the enter key"
                    )
            )
        )


{-| -}
onTabWithPreventDefault : msg -> Element.Attribute msg
onTabWithPreventDefault msg =
    onKeyWithPreventDefault tabKeyCode msg


onArrowDownWithPreventDefault : msg -> Element.Attribute msg
onArrowDownWithPreventDefault msg =
    onKeyWithPreventDefault arrowDownKeyCode msg


onArrowUpWithPreventDefault : msg -> Element.Attribute msg
onArrowUpWithPreventDefault msg =
    onKeyWithPreventDefault arrowUpKeyCode msg


arrowUpKeyCode =
    "ArrowUp"


arrowDownKeyCode =
    "ArrowDown"


tabKeyCode =
    "Tab"


enterKeyCode =
    "Enter"


backspaceKeyCode =
    "Backspace"


onKeysDown : List ( String, msg ) -> Element.Attribute msg
onKeysDown keys =
    Element.htmlAttribute <|
        Html.Events.preventDefaultOn "keydown"
            (Decode.field "key" Decode.string
                |> Decode.andThen
                    (\key ->
                        List.filterMap
                            (\( k, m ) ->
                                if k == key then
                                    Just <| Decode.succeed ( m, True )

                                else
                                    Nothing
                            )
                            keys
                            |> List.head
                            |> Maybe.withDefault (Decode.fail ("None of the keycodes matched '" ++ key ++ "'"))
                    )
            )


{-| -}
onKeyWithPreventDefault : String -> msg -> Element.Attribute msg
onKeyWithPreventDefault keyCode msg =
    Element.htmlAttribute
        (Html.Events.preventDefaultOn "keydown"
            (Decode.field "key" Decode.string
                |> Decode.andThen
                    (\key ->
                        if key == keyCode then
                            Decode.succeed ( msg, True )

                        else
                            Decode.fail <| "Not the " ++ keyCode ++ "keyCode. (Was " ++ key ++ ")"
                    )
            )
        )
