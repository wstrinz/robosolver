module RobosolverClient where
import RobosolverView exposing (view)
import RobosolverModel exposing (actions, model)
import Html exposing (Html, div, text, button, p, br)
import Html.Attributes exposing (src, attribute, style)
import Html.Events exposing (onClick)
import Signal -- exposing (Html)
import List exposing (map , (::))
import Set exposing (Set, singleton)

main : Signal Html.Html
main = Signal.map (view actions.address) model
