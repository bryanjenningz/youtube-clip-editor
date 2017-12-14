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
    , clips : List Clip
    }


type alias Clip =
    { text : String
    , start : Float
    , end : Float
    }


init : List Clip -> ( Model, Cmd Msg )
init clips =
    ( { text = ""
      , startTime = 0
      , endTime = 0
      , currentTime = 0
      , clipPlaying = False
      , clips = clips
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
    | SaveClip
    | DeleteClip Int


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

        SaveClip ->
            let
                newClip =
                    { start = model.startTime, end = model.endTime, text = model.text }

                newClips =
                    (newClip :: model.clips)
                        |> List.sortBy .start
            in
            ( { model | clips = newClips }, saveClips newClips )

        DeleteClip index ->
            let
                newClips =
                    List.take index model.clips ++ List.drop (index + 1) model.clips
            in
            ( { model | clips = newClips }, saveClips newClips )


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
        , div []
            [ button [ onClick SaveClip ] [ text "Save Clip" ] ]
        , div [] (List.indexedMap viewClip model.clips)
        ]


viewClip : Int -> Clip -> Html Msg
viewClip index clip =
    div []
        [ text <|
            "Start: "
                ++ toString clip.start
                ++ " "
                ++ "End: "
                ++ toString clip.end
                ++ " Text: "
                ++ clip.text
        , button [ onClick (DeleteClip index) ] [ text "x" ]
        ]



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    getCurrentTime SetCurrentTime



---- PORTS ----


port getCurrentTime : (Float -> msg) -> Sub msg


port playVideo : Float -> Cmd msg


port pauseVideo : () -> Cmd msg


port saveClips : List Clip -> Cmd msg



---- PROGRAM ----


main : Program (List Clip) Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
