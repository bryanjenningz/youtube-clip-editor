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
    , clipPlaying : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { text = ""
      , startTime = 0
      , endTime = 0
      , currentTime = 0
      , clipPlaying = False
      }
    , Cmd.none
    )



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
            ( { model | startTime = roundTenths time }, Cmd.none )

        SetEndTime time ->
            ( { model | endTime = roundTenths time }, Cmd.none )

        SetCurrentTime currentTime ->
            if model.clipPlaying && model.currentTime >= model.endTime then
                ( { model | currentTime = roundTenths currentTime, clipPlaying = False }, pauseVideo () )
            else
                ( { model | currentTime = roundTenths currentTime }, Cmd.none )

        PauseClip ->
            ( { model | clipPlaying = False }, pauseVideo () )

        PlayClip time ->
            ( { model | clipPlaying = True, currentTime = model.startTime }, playVideo time )


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
        , div []
            [ button [ onClick <| SetStartTime model.currentTime ] [ text "Set Start Time" ]
            , button [ onClick <| SetStartTime (model.startTime - 0.1) ] [ text "<" ]
            , button [ onClick <| SetStartTime (model.startTime + 0.1) ] [ text ">" ]
            ]
        , div []
            [ button [ onClick <| SetEndTime model.currentTime ] [ text "Set End Time" ]
            , button [ onClick <| SetEndTime (model.endTime - 0.1) ] [ text "<" ]
            , button [ onClick <| SetEndTime (model.endTime + 0.1) ] [ text ">" ]
            ]
        , div []
            [ button
                [ onClick <| PlayClip model.startTime ]
                [ text "Play Clip" ]
            ]
        ]



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    getCurrentTime SetCurrentTime



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
