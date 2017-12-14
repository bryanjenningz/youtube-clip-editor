port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time


---- MODEL ----


type alias Model =
    { text : String
    , startTime : Float
    , endTime : Float
    , currentTime : Float
    , clipPlaying : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { text = "", startTime = 0, endTime = 0, currentTime = 0, clipPlaying = False }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | SetText String
    | SetStartTime Float
    | SetEndTime Float
    | SetCurrentTime Float
    | PlayClip Float
    | PauseClip


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetText text ->
            ( { model | text = text }, Cmd.none )

        SetStartTime time ->
            ( { model | startTime = time }, Cmd.none )

        SetEndTime time ->
            ( { model | endTime = time }, Cmd.none )

        SetCurrentTime currentTime ->
            ( { model | currentTime = roundTenths currentTime }, Cmd.none )

        PlayClip time ->
            ( { model | clipPlaying = True }, playVideo time )

        PauseClip ->
            ( { model | clipPlaying = False }, pauseVideo () )


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
        , button [ onClick <| SetStartTime model.currentTime ] [ text "Set Start Time" ]
        , button [ onClick <| SetEndTime model.currentTime ] [ text "Set End Time" ]
        , div []
            [ button [ onClick <| PlayClip model.startTime ]
                [ text
                    (if model.clipPlaying then
                        "Pause Clip"
                     else
                        "Play Clip"
                    )
                ]
            ]
        ]



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.clipPlaying then
        Sub.batch
            [ getCurrentTime SetCurrentTime
            , Time.every (Time.millisecond * 50) (always (monitorClip model.currentTime model.endTime))
            ]
    else
        getCurrentTime SetCurrentTime


monitorClip : Float -> Float -> Msg
monitorClip currentTime endTime =
    if currentTime >= endTime then
        PauseClip
    else
        NoOp



---- PORTS ----


port getCurrentTime : (Float -> msg) -> Sub msg


port playVideo : Float -> Cmd msg


port pauseVideo : () -> Cmd msg



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
