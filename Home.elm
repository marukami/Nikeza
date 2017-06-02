module Home exposing (..)

import Domain.Core exposing (..)
import Controls.Login as Login exposing (..)
import Settings exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Navigation exposing (..)


-- elm-live Home.elm --open --output=home.js
-- elm-make Home.elm --output=home.html
-- elm-make Domain/Contributor.elm --output=Domain/Contributor.html
-- elm-package install elm-lang/navigation


main =
    Navigation.program UrlChange
        { init = model
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }



-- MODEL


type alias Model =
    { page : Page
    , content : Content
    , contributors : List Contributor
    , login : Login.Model
    }


type alias Content =
    { videos : List Video
    , articles : List Article
    , podcasts : List Podcast
    }


model : Navigation.Location -> ( Model, Cmd Msg )
model location =
    ( { page = HomePage
      , content = Content [] [] []
      , contributors = []
      , login = Login.model
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = UrlChange Navigation.Location
    | Video Video
    | Article Article
    | Contributor Contributor
    | Search String
    | Register
    | OnLogin Login.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange location ->
            { model | page = (getPage location.hash) } ! [ Cmd.none ]

        Video v ->
            ( model, Cmd.none )

        Article v ->
            ( model, Cmd.none )

        Contributor v ->
            ( model, Cmd.none )

        Search v ->
            ( model, Cmd.none )

        Register ->
            ( model, Cmd.none )

        OnLogin subMsg ->
            case subMsg of
                Login.Attempt v ->
                    let
                        latest =
                            Login.update subMsg model.login
                    in
                        ( { model | login = runtime.tryLogin latest }, Cmd.none )

                Login.UserInput _ ->
                    ( { model | login = Login.update subMsg model.login }, Cmd.none )

                Login.PasswordInput _ ->
                    ( { model | login = Login.update subMsg model.login }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model.page of
        HomePage ->
            div []
                [ header []
                    [ label [] [ text "Nikeza" ]
                    , model |> renderLogin
                    ]
                , div [] contributors
                , footer [ class "copyright" ]
                    [ label [] [ text "(c)2017" ]
                    , a [ href "" ] [ text "GitHub" ]
                    ]
                ]

        _ ->
            div [] [ text "Not Found" ]


contributors : List (Html Msg)
contributors =
    runtime.recentContributors |> List.map thumbnail


thumbnail : Profile -> Html Msg
thumbnail profile =
    let
        formatTopic topic =
            a [ href <| getUrl <| topicUrl runtime.topicUrl profile.id topic ] [ i [] [ text <| gettopic topic ] ]

        concatTopics topic1 topic2 =
            span []
                [ topic1
                , label [] [ text " " ]
                , topic2
                , label [] [ text " " ]
                ]

        topics =
            List.foldr concatTopics (div [] []) (profile.topics |> List.map formatTopic)

        topicsAndBio =
            div []
                [ topics
                , br [] []
                , label [] [ text profile.bio ]
                ]
    in
        div []
            [ table []
                [ tr []
                    [ td []
                        [ a [ href <| getUrl <| runtime.contributorUrl profile.id ]
                            [ img [ src <| getUrl profile.imageUrl, width 50, height 50 ] [] ]
                        ]
                    , td [] [ topicsAndBio ]
                    ]
                ]
            , label [] [ text (profile.name |> getName) ]
            ]


renderLogin : Model -> Html Msg
renderLogin model =
    let
        loggedIn =
            model.login.loggedIn

        welcome =
            p [] [ text <| "Welcome " ++ model.login.username ++ "!" ]

        signout =
            a [ href "" ] [ label [] [ text "Signout" ] ]
    in
        if (not loggedIn) then
            Html.map OnLogin <| Login.view model.login
        else
            div [ class "signin" ] [ welcome, signout ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- NAVIGATION


type Page
    = HomePage
    | ContributorsPage
    | ContributorPage
    | NotFound


getPage : String -> Page
getPage hash =
    case hash of
        "#home" ->
            HomePage

        _ ->
            NotFound
