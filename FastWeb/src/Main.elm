module Main exposing (..)

import Browser
import Colors
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input exposing (search)
import Element.Lazy
import ElementExt
import Fest.Atc exposing (Atc)
import Fest.Interaksjon exposing (Interaksjon, Relevans)
import Fest.InteraksjonCouple exposing (InteraksjonCouple)
import Fest.Legemiddel exposing (Legemiddel)
import Fest.Substans exposing (Substans)
import Html exposing (Html)
import Http
import Json.Decode as Decode
import List.Extra
import Process
import Task
import Url.Builder



---- MODEL ----


type RemoteData error a
    = NotAsked
    | Loading
    | Failure error
    | Success a


type alias WebData a =
    RemoteData Http.Error a


type alias Model =
    { searchInput : String
    , focusIndex : Int
    , results : List Legemiddel
    , selectedResults : List Legemiddel
    , interaksjoner : WebData (List InteraksjonCouple)
    }


initialModel : Model
initialModel =
    { searchInput = ""
    , results = []
    , focusIndex = 0
    , selectedResults = []
    , interaksjoner = NotAsked
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp
    | SearchInputChanged String
    | SearchInputDebounce String
    | GotSearchResults (Result Http.Error (List Legemiddel))
    | RemoveSelectedResult Legemiddel
    | AddSelectedResult (Maybe Legemiddel)
    | GotInteraksjoner (List Legemiddel) (Result Http.Error (List InteraksjonCouple))
    | FocusIndexChanged Int
    | ClearResultList


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SearchInputChanged newText ->
            ( { model | searchInput = newText }, Task.perform SearchInputDebounce (Process.sleep 500.0 |> Task.andThen (\_ -> Task.succeed newText)) )

        SearchInputDebounce oldText ->
            if oldText /= model.searchInput then
                ( model, Cmd.none )

            else
                ( model, legemiddelRequest model.searchInput )

        GotSearchResults r ->
            case r of
                Err err ->
                    Debug.log (Debug.toString err) ( { model | searchInput = "Error!" }, Cmd.none )

                Ok res ->
                    ( { model | results = res, focusIndex = 0 }, Cmd.none )

        RemoveSelectedResult r ->
            let
                newResults =
                    List.filter (\x -> x /= r) model.selectedResults
            in
            ( { model | selectedResults = newResults, interaksjoner = Loading }, interaksjonRequest newResults )

        AddSelectedResult maybeSelected ->
            case maybeSelected of
                Nothing ->
                    ( model, Cmd.none )

                Just selected ->
                    let
                        newResults =
                            unique (selected :: model.selectedResults)
                    in
                    ( { model | selectedResults = newResults, results = [], searchInput = "", interaksjoner = Loading }, interaksjonRequest newResults )

        GotInteraksjoner control r ->
            if model.selectedResults /= control then
                ( model, Cmd.none )

            else
                case r of
                    Err err ->
                        Debug.log (Debug.toString err) ( { model | interaksjoner = Failure err }, Cmd.none )

                    Ok res ->
                        ( { model | interaksjoner = Success res }, Cmd.none )

        FocusIndexChanged newIndex ->
            let
                index =
                    Basics.min (List.length model.results - 1) (Basics.max 0 newIndex)
            in
            ( { model | focusIndex = index }, Cmd.none )

        ClearResultList ->
            ( { model | results = [] }, Cmd.none )


baseUrlBuilder =
    Url.Builder.crossOrigin "http://10.0.0.12:5000"


legemiddelRequest : String -> Cmd Msg
legemiddelRequest search =
    Http.get
        { url = baseUrlBuilder [ "api", "legemiddel", "virkestoff" ] [ Url.Builder.string "search" search, Url.Builder.int "take" 10 ]
        , expect = Http.expectJson GotSearchResults (Decode.list Fest.Legemiddel.decode)
        }


interaksjonRequest : List Legemiddel -> Cmd Msg
interaksjonRequest legemiddels =
    let
        url =
            baseUrlBuilder [ "api", "interaksjon", "couple" ]
                (List.filterMap (\x -> x.maybeAtc) legemiddels
                    |> List.map (\x -> Url.Builder.string "atcVs" <| Fest.Atc.asString x.v)
                )
    in
    Http.get
        { url = Debug.log "Url:" url
        , expect = Http.expectJson (GotInteraksjoner legemiddels) (Decode.list Fest.InteraksjonCouple.decode)
        }



---- VIEW ----


view : Model -> Html Msg
view model =
    Element.layout [ Font.family [ Font.sansSerif ], inFront viewFooter ]
        (column
            [ width fill ]
            [ viewHeaderRow
            , viewContent model
            ]
        )


viewFooter : Element Msg
viewFooter =
    row
        [ width fill
        , height (px 60)
        , Background.color <| Colors.accentColor
        , padding 10
        , alignBottom
        ]
        [ paragraph [ Font.center, Font.size 14, Font.color <| Colors.white ]
            [ text "⚠️ Fast er kun en prototype og må aldri brukes for legemiddelinteraksjoner. Se "
            , newTabLink [] { url = "https://interaksjoner.no", label = el [ Element.mouseOver [ Background.color <| rgb255 0 100 255 ] ] <| text "interaksjoner.no" }
            , text "."
            ]
        ]


viewHeaderRow : Element Msg
viewHeaderRow =
    row [ width fill, height (px 60), Background.color <| Colors.accentColor, padding 10 ] [ el [ Font.size 30, Font.color <| Colors.white ] (text "⏩ Fast") ]


viewContent : Model -> Element Msg
viewContent model =
    column
        [ width (fill |> maximum 1000)
        , centerX
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ row [ spacing 2 ] [ wrappedRow [ width fill ] (List.map viewSelectedResult (List.reverse model.selectedResults)) ]
            , row
                [ width
                    (fill
                        |> minimum 250
                    )
                ]
                [ let
                    focusedItem =
                        List.Extra.getAt model.focusIndex model.results
                  in
                  Input.search
                    ([ Font.alignLeft
                     , Font.bold
                     , Input.focusedOnLoad
                     , ElementExt.onKeysDown
                        ([ ( ElementExt.tabKeyCode, AddSelectedResult focusedItem )
                         , ( "Escape", ClearResultList )
                         , ( ElementExt.enterKeyCode, AddSelectedResult focusedItem )
                         , ( ElementExt.arrowUpKeyCode, FocusIndexChanged (model.focusIndex - 1) )
                         , ( ElementExt.arrowDownKeyCode, FocusIndexChanged (model.focusIndex + 1) )
                         ]
                            ++ (if model.searchInput == "" then
                                    case model.selectedResults of
                                        [] ->
                                            []

                                        x :: _ ->
                                            [ ( ElementExt.backspaceKeyCode, RemoveSelectedResult x ) ]

                                else
                                    []
                               )
                        )
                     ]
                        ++ (case model.results of
                                [] ->
                                    []

                                _ ->
                                    [ Element.below
                                        (column
                                            [ width (fill |> maximum 800), spacing 5, Background.color <| Colors.white ]
                                            (List.map
                                                (\legemiddel ->
                                                    viewSearchSuggestionItem legemiddel focusedItem
                                                )
                                                model.results
                                            )
                                        )
                                    ]
                           )
                    )
                    { onChange = SearchInputChanged
                    , text = model.searchInput
                    , placeholder = Just (Input.placeholder [] (text "Søk legemiddel"))
                    , label = Input.labelHidden "Search"
                    }
                ]
            ]
        , model.interaksjoner
            |> Element.Lazy.lazy
                (\x ->
                    column
                        [ width fill
                        , spacing 10
                        , padding 10
                        ]
                        (case x of
                            NotAsked ->
                                []

                            Loading ->
                                [ text "Oppdaterer" ]

                            Failure _ ->
                                [ text "Noe gikk galt." ]

                            Success res ->
                                case res of
                                    [] ->
                                        case model.selectedResults of
                                            [] ->
                                                []

                                            _ ->
                                                [ paragraph [] [ text "Ingen kjente legemiddelinteraksjoner." ] ]

                                    r ->
                                        r
                                            |> List.sortBy (\y -> y.interaksjon.relevans.v)
                                            |> List.map viewInteraksjonCouple
                        )
                )
        ]


viewSearchSuggestionItem : Legemiddel -> Maybe Legemiddel -> Element Msg
viewSearchSuggestionItem legemiddel focusedItem =
    let
        isFocused =
            Just legemiddel == focusedItem
    in
    Input.button [ width fill ]
        { onPress = Just <| AddSelectedResult <| Just legemiddel
        , label =
            row
                ([ padding 16
                 , width fill
                 , Border.rounded 4
                 ]
                    ++ (if isFocused then
                            [ Background.color <| Colors.white
                            , Border.width 1
                            ]

                        else
                            [ Background.color (Element.rgb255 245 245 255) ]
                       )
                    ++ [ focused
                            [ Background.color <| Colors.white
                            ]
                       , mouseOver
                            [ Background.color <| Colors.white
                            ]
                       ]
                )
                [ paragraph [ width fill ]
                    [ text <|
                        case legemiddel.maybeAtc of
                            Just atc ->
                                atc.descriptiveName

                            Nothing ->
                                "Ingen ATC"
                    ]
                , if isFocused then
                    paragraph [ width shrink, Element.alignRight ] [ text " Velg med enter" ]

                  else
                    Element.none
                ]
        }


viewInteraksjonCouple : InteraksjonCouple -> Element Msg
viewInteraksjonCouple { substansA, substansB, interaksjon } =
    wrappedRow
        [ width
            fill
        , Border.rounded 10
        , Background.color <| Colors.white
        , Border.shadow { offset = ( 0, 1.0 ), size = 0.1, blur = 0, color = rgb255 220 220 220 }
        ]
        [ column [ width fill, Font.alignLeft ]
            [ wrappedRow [ spacing 10, width fill ]
                [ el
                    [ Element.alignTop
                    , width shrink
                    , padding 10
                    , Border.rounded 100
                    , Background.color (getRiskColor interaksjon.relevans)
                    ]
                    (el [ centerX, centerY ] (text interaksjon.relevans.dn))
                , viewSubstansItem substansA

                --- , text "med"
                , viewSubstansItem substansB
                ]
            , paragraph [] [ text <| Maybe.withDefault "" interaksjon.interaksjonsmekanisme ]
            , paragraph [] [ text interaksjon.kliniskKonsekvens ]
            ]
        ]


getAtcText : Maybe Atc -> String
getAtcText maybeAtc =
    maybeAtc
        |> Maybe.map (\x -> Fest.Atc.toFormattedString x.v)
        |> Maybe.withDefault ""


getRiskColor : Relevans -> Color
getRiskColor relevans =
    case relevans.v of
        "1" ->
            Colors.riskHighColor

        "2" ->
            Colors.riskMediumColor

        "3" ->
            Colors.riskLowColor

        _ ->
            rgb255 100 100 100


viewSubstansItem : Substans -> Element Msg
viewSubstansItem substans =
    Element.row [ width (fill |> maximum 300), Background.color <| Colors.substansBackground, Border.rounded 4, padding 4, spacing 2 ]
        [ paragraph [ width fill, Font.color Colors.substansFont ]
            [ text <|
                getAtcText substans.maybeAtc
            , text " "
            , el [ Font.justify ] <|
                text <|
                    substans.substans
            ]
        ]


viewSelectedResult : Legemiddel -> Element Msg
viewSelectedResult legemiddel =
    Element.row [ width (fill |> minimum 300), Background.color <| Colors.substansBackground, Font.color Colors.substansFont, Border.rounded 4, paddingXY 15 8, spacing 10 ]
        [ paragraph [ width fill, Font.alignLeft ]
            [ text
                (legemiddel.maybeAtc
                    |> Maybe.map (\x -> Fest.Atc.toFormattedString x.v ++ ": " ++ x.descriptiveName)
                    |> Maybe.withDefault
                        legemiddel.navnFormStyrke
                )
            ]
        , Input.button
            [ Background.color (rgb255 0 180 200)
            , Element.mouseOver [ Background.color <| rgb255 0 100 255 ]
            , Element.focused [ Background.color <| rgb255 0 120 255 ]
            , Border.rounded 1000
            , alignRight
            ]
            { onPress = Just <| RemoveSelectedResult legemiddel
            , label = el [ Font.color <| Colors.white, Font.size 20, paddingXY 10 6, alignRight ] (text "x")
            }
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }



---- UTILS ----


{-| Get distinct items in a list. Kinda slow (O(n^2 ish?)), use on small lists.
Taken from: <https://diogoaos.medium.com/how-to-get-unique-values-in-an-elm-list-d91ec7dfd0e>
-}
unique : List a -> List a
unique list =
    let
        incUnique : a -> List a -> List a
        incUnique elem lst =
            if List.member elem lst then
                lst

            else
                elem :: lst
    in
    List.foldr incUnique [] list
