module HelloTest exposing (..)

import Controls.Login as Login exposing (Model)
import Tests.TestAPI exposing (..)
import Home exposing (..)
import Settings exposing (..)
import Navigation exposing (..)
import Test exposing (..)
import Expect


-- TODO: https://stackoverflow.com/questions/44909872/executing-elm-test-throws-runtime-exception-cannot-read-property-href-of-unde/44979563#44979563


suite : Test
suite =
    describe "My Tests"
        [ test "runtime.tryLogin succeeds with valid credentials" <|
            \_ ->
                let
                    login =
                        Login.Model "test" "test" False

                    result =
                        runtime.tryLogin login
                in
                    Expect.equal result.loggedIn True
        , test "runtime.tryLogin fails with invalid credentials" <|
            \_ ->
                let
                    login =
                        Login.Model "test" "invalid_password" False

                    result =
                        runtime.tryLogin login
                in
                    Expect.equal result.loggedIn False
        , test "search yields profile" <|
            \_ ->
                let
                    -- Setup
                    location =
                        Navigation.Location "" "" "" "" "" "" "" "" "" "" ""

                    ( model, _ ) =
                        Home.init location

                    -- Test
                    ( newState, _ ) =
                        model |> Home.update (Search "Scott")

                    -- Verify
                    ( onlyOne, isContentProvider1 ) =
                        ( (newState.contentProviders |> List.length) == 1
                        , newState.contentProviders |> List.member contentProvider1
                        )
                in
                    Expect.equal (onlyOne && isContentProvider1) True
        ]
