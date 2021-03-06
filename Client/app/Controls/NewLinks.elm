module Controls.NewLinks exposing (..)

import Settings exposing (..)
import Domain.Core exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (map)


-- MODEL


type alias Model =
    NewLinks


type Msg
    = InputTitle String
    | InputUrl String
    | InputTopic String
    | RemoveTopic Topic
    | InputContentType String
    | AddLink NewLinks
    | AssociateTopic Topic



-- UPDATE


update : Msg -> Model -> Model
update msg model =
    let
        linkToCreate =
            model.current

        linkToCreateBase =
            model.current.base
    in
        case msg of
            InputTitle v ->
                { model | current = { linkToCreate | base = { linkToCreateBase | title = Title v } } }

            InputUrl v ->
                { model | current = { linkToCreate | base = { linkToCreateBase | url = Url v } } }

            InputTopic v ->
                { model | current = { linkToCreate | currentTopic = Topic v False } }

            RemoveTopic v ->
                { model | current = { linkToCreate | base = { linkToCreateBase | topics = linkToCreateBase.topics |> List.filter (\t -> t /= v) } } }

            AssociateTopic v ->
                { model | current = { linkToCreate | currentTopic = Topic "" False, base = { linkToCreateBase | topics = v :: linkToCreateBase.topics } } }

            InputContentType v ->
                { model | current = { linkToCreate | base = { linkToCreateBase | contentType = toContentType v } } }

            AddLink v ->
                v



-- VIEW


view : Model -> Html Msg
view model =
    let
        toButton topic =
            div []
                [ button [ onClick <| AssociateTopic topic ] [ text <| getTopic topic ]
                , br [] []
                ]

        topicsSelectionUI search =
            div []
                (search
                    |> getTopic
                    |> runtime.suggestedTopics
                    |> List.map toButton
                )

        selectedTopicsUI =
            current.base.topics |> List.map (\t -> label [] [ text <| getTopic t, button [ class "remove", onClick <| RemoveTopic t ] [ text "Remove" ], br [] [] ])

        ( current, base ) =
            ( model.current, model.current.base )

        listbox =
            select [ Html.Events.on "change" (Json.Decode.map InputContentType Html.Events.targetValue) ]
                [ option [ value "instructions" ] [ text "Content Type" ]
                , option [ value "Article" ] [ text "Article" ]
                , option [ value "Video" ] [ text "Video" ]
                , option [ value "Answer" ] [ text "Answer" ]
                , option [ value "Podcast" ] [ text "Podcast" ]
                ]
    in
        div []
            [ h2 [] [ text "Link" ]
            , table []
                [ tr []
                    [ td []
                        [ table []
                            [ tr []
                                [ td [] [ input [ class "addLinkText", type_ "text", placeholder "title", onInput InputTitle, value <| getTitle base.title ] [] ]
                                ]
                            , tr [] [ td [] [ input [ class "addLinkText", type_ "text", placeholder "link", onInput InputUrl, value <| getUrl base.url ] [] ] ]
                            , tr []
                                [ td []
                                    [ table []
                                        [ tr []
                                            [ td [] [ input [ type_ "text", placeholder "topic", onInput InputTopic, value (getTopic current.currentTopic) ] [] ]
                                            , td [] [ listbox ]
                                            ]
                                        ]
                                    ]
                                ]
                            , tr [] [ td [] [ topicsSelectionUI current.currentTopic ] ]
                            , tr [] [ td [] [ div [] selectedTopicsUI ] ]
                            ]
                        ]
                    , td [] [ button [ class "addLink", onClick <| AddLink model ] [ text "Add Link" ] ]
                    ]
                ]
            ]
