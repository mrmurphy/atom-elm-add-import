port module Main exposing (..)

import Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events.Extra exposing (onEnter)
import Task
import AddImport


port open : (String -> msg) -> Sub msg


port importAdded : String -> Cmd msg


inputStyle : List ( String, String )
inputStyle =
    [ ( "display", "block" )
    , ( "width", "100%" )
    , ( "background", "none" )
    , ( "border", "none" )
    , ( "border-bottom", "1px solid white" )
    , ( "font-size", "1.2em" )
    ]


labelStyle : List ( String, String )
labelStyle =
    [ ( "display", "block" )
    , ( "font-size", "1.2em" )
    ]


baseStyle : List a
baseStyle =
    []


type alias Model =
    { input : String
    , moduleName : String
    , symbolName : Maybe String
    , editorContents : String
    , error : String
    }


init : ( Model, Cmd Msg )
init =
    { input = ""
    , moduleName = ""
    , symbolName = Nothing
    , editorContents = ""
    , error = ""
    }
        ! []


type Msg
    = Open String
    | ChangeInput String
    | NoOp
    | GO


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ open Open
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Open editorContents ->
            { model | editorContents = editorContents } ! [ Task.attempt (always NoOp) <| Dom.focus "AddImportInput" ]

        NoOp ->
            model ! []

        ChangeInput newVal ->
            let
                ( fst, snd ) =
                    case String.split " " newVal of
                        fst :: [] ->
                            ( fst, Nothing )

                        fst :: snd :: [] ->
                            ( fst
                            , if snd == "" then
                                Nothing
                              else
                                Just snd
                            )

                        _ ->
                            ( "", Nothing )
            in
                { model
                    | input = newVal
                    , moduleName = fst
                    , symbolName = snd
                }
                    ! []

        GO ->
            let
                result =
                    AddImport.addImport model.moduleName model.symbolName model.editorContents
            in
                case result of
                    Ok newContents ->
                        let
                            ( initMdl, _ ) =
                                init
                        in
                            initMdl ! [ importAdded newContents ]

                    Err e ->
                        { model | error = toString e } ! []


view : Model -> Html Msg
view model =
    div [ style baseStyle ]
        [ label [ style labelStyle ]
            [ text "Module name and optional symbol separated by a space"
            , input
                [ style inputStyle
                , autofocus True
                , id "AddImportInput"
                , onInput ChangeInput
                , onEnter GO
                , value model.input
                ]
                []
            ]
        , div [ style [ ( "padding", "0.75rem 1rem" ), ( "font-size", "1.2rem" ) ] ]
            [ div [] [ text <| "Module name: " ++ model.moduleName ]
            , div [] [ text <| "Symbol name: " ++ (Maybe.withDefault "none" model.symbolName) ]
            , div [ style [ ( "color", "tomato" ) ] ] [ text <| model.error ]
            ]
        ]
