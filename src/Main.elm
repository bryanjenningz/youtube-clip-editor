port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


---- MODEL ----


type alias Model =
    { text : String
    , startTime : Float
    , endTime : Float
    , currentTime : Float
    , playingClip : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { text = "", startTime = 0, endTime = 0, currentTime = 0, playingClip = False }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | SetText String
    | SetStartTime
    | SetEndTime
    | SetCurrentTime Float
    | PlayClip


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetText text ->
            ( { model | text = text }, Cmd.none )

        SetStartTime ->
            ( { model | startTime = model.currentTime }, Cmd.none )

        SetEndTime ->
            ( { model | endTime = model.currentTime }, Cmd.none )

        SetCurrentTime currentTime ->
            ( { model | currentTime = roundTenths currentTime }, Cmd.none )

        PlayClip ->
            ( model, Cmd.none )


roundTenths : Float -> Float
roundTenths n =
    (toFloat << round) (n * 10) / 10



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "YouTube Clip Editor" ]
        , div [] [ text <| "Start: " ++ toString model.startTime ]
        , div [] [ text <| "End: " ++ toString model.endTime ]
        , input [ placeholder "Clip text", onInput SetText ] []
        , button [ onClick SetStartTime ] [ text "Set Start Time" ]
        , button [ onClick SetEndTime ] [ text "Set End Time" ]
        ]



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    getCurrentTime SetCurrentTime



---- PORTS ----


port getCurrentTime : (Float -> msg) -> Sub msg



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
