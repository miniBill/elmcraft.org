module Theme exposing (..)

import Colors exposing (..)
import DateFormat
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Region as Region
import Helpers exposing (..)
import Html exposing (Html)
import Route
import Theme.Footer
import Theme.Layout
import Theme.Navigation
import Theme.UI exposing (..)
import Time
import Timestamps
import Types
import View exposing (..)


view : a -> (Types.Msg -> wrapperMsg) -> Types.Model -> View.View wrapperMsg -> Html wrapperMsg
view x toWrapperMsg model static =
    layout
        [ width fill
        , Font.size 18
        , Font.family [ Font.typeface Theme.Layout.fontFace ]
        , Font.color charcoal
        , width fill
        ]
    <|
        column [ width fill ]
            [ manualCss
            , column
                [ width fill
                , spacing 20
                ]
                [ Theme.Navigation.navigation model static.route
                    |> Element.map toWrapperMsg

                -- , el [ width fill ] <| html <| Html.pre [] [ Html.text <| Debug.toString x ]
                , if static.route == Route.SPLAT__ { splat = [] } then
                    none

                  else
                    standardCenteredSectionAdaptiveAt
                        Theme.Layout.maxWidth
                        model
                        white
                        []
                        [ heading1 static.title
                        , el [ Background.color grey, width fill, height (px 2) ] none
                        , let
                            statusToString status =
                                case status of
                                    Seedling ->
                                        "Seedling 🌱"

                                    Budding ->
                                        "Budding \u{1FAB4}"

                                    Evergreen ->
                                        "Evergreen 🌳"
                          in
                          case static.status of
                            Just status ->
                                row [ width fill ]
                                    [ el [ paddingXY 0 10, width fill ] <|
                                        paragraph [ Font.color charcoalLight, Font.size 14 ] <|
                                            [ prefetchLink [ Font.color <| fromHex "#98B68F" ] { url = "/about/markers", label = text <| statusToString status }
                                            , text <| " Planted " ++ format static.timestamps.created ++ " - Last tended " ++ format static.timestamps.updated
                                            ]
                                    , if not static.published && model.isDev then
                                        el [ Background.color elmcraftNude ] <| text "not published"

                                      else
                                        none
                                    ]

                            Nothing ->
                                -- For now, if we don't have a status, don't show dates either (covers us for pages like indexes where it's a bit odd?)
                                none
                        ]
                        |> Element.map toWrapperMsg
                , standardCenteredSection
                    model
                    white
                    [ Region.mainContent ]
                    static.content
                , Theme.Footer.view model
                    |> Element.map toWrapperMsg
                ]
            ]


manualCss =
    html <|
        Html.node "style"
            []
            [ Html.text <|
                """
            @import url('https://rsms.me/inter/inter.css');
            html, body { font-family: 'Inter', system-ui, sans-serif; width: 100%; }
            @supports (font-variation-settings: normal) {
              html, body { font-family: 'Inter var', system-ui, sans-serif; }
            }
            """
            ]


format : Time.Posix -> String
format posix =
    DateFormat.format
        [ DateFormat.monthNameAbbreviated
        , DateFormat.text " "
        , DateFormat.dayOfMonthNumber
        , DateFormat.text ", "
        , DateFormat.yearNumber
        ]
        Time.utc
        posix
