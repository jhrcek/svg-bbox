port module Main exposing (..)

import Html exposing (Html, text)
import Html.Attributes exposing (value)
import Html.Events exposing (onInput)
import Svg exposing (Svg)
import Svg.Attributes as Attr exposing (fill, height, id, stroke, strokeWidth, width, x, y)


type alias Model =
    { svgtext : String
    , mBox : Maybe BBox
    }


type alias BBox =
    { x : Float, y : Float, width : Float, height : Float }


type Msg
    = ChangeText String
    | SetBBox BBox


textId : String
textId =
    "txt1"



-- request bounding box of svg element with given String id


port requestBBox : String -> Cmd msg



-- receive Bounding Box from js


port setBBox : (BBox -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    setBBox SetBBox


init : ( Model, Cmd Msg )
init =
    ( Model "Svg text in a box" Nothing
    , requestBBox textId
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeText newText ->
            ( { model | svgtext = newText }, requestBBox textId )

        SetBBox bbox ->
            ( { model | mBox = Just bbox }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        svgText =
            Svg.text_ [ x "1", y "50", id textId ] [ Svg.text model.svgtext ]

        svgChildren =
            case model.mBox of
                Nothing ->
                    [ svgText ]

                Just bbox ->
                    [ viewBox bbox, svgText ]
    in
        Html.div []
            [ Html.input [ onInput ChangeText, value model.svgtext ] []
            , Html.div [] [ Svg.svg [ width "100%", height "200px" ] svgChildren ]
            ]


viewBox : BBox -> Svg Msg
viewBox { x, y, width, height } =
    Svg.rect
        [ Attr.x (toString x)
        , Attr.y (toString y)
        , Attr.width (toString width ++ "px")
        , Attr.height (toString height ++ "px")
        , stroke "black"
        , fill "white"
        , strokeWidth "1px"
        ]
        []


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
