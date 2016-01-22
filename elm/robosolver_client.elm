module RobosolverClient where
import RobosolverTypes exposing (..)
import RobosolverQueries exposing (..)
import RobosolverView exposing (view)
import RobosolverModel exposing (..)
import Html exposing (Html, div, text, button, p, br)
import Html.Attributes exposing (src, attribute, style)
import Html.Events exposing (onClick)
import Signal -- exposing (Html)
import List exposing (map , (::))
import Set exposing (Set, singleton)

main : Signal Html.Html
main = Signal.map (view actions.address) model


-- port playSong : Signal String
-- port playSong = Signal.map toString playerActions.signal

-- port songPos : Signal Float
