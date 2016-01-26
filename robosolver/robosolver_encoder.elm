module RobosolverEncoder (modelToJson) where
{-| Robosolver Encoder

# Types
@docs modelToJson
-}
import Set exposing (Set)
import Dict exposing (Dict)
import Json.Encode as ENC exposing (string, int, object, list, bool)
import RobosolverTypes exposing (..)

{-| modelToJson -}
modelToJson : Model -> String
modelToJson model = ENC.encode 0 (jModel model)

jModel : Model -> ENC.Value
jModel model = object [
    ("board", jBoard model.board),
    ("activeCells", jActiveCells model.activeCells),
    ("isClicking", bool model.isClicking)
  ]

jBoard : Board -> ENC.Value
jBoard board = object [
    ("maxx", int board.maxx),
    ("maxy", int board.maxy),
    ("cells", jCellDict board.cells),
    ("walls", jWalls board.walls),
    ("robits", jRobits board.robits)
  ]

jCellDict : Dict (Int, Int) Cell -> ENC.Value
jCellDict cellDict = list
                      <| List.map jCell
                      <| Dict.values cellDict

jCells : List Cell -> ENC.Value
jCells cells = list <| List.map jCell cells

jCell : Cell -> ENC.Value
jCell cell = object [
  ("name", string cell.name),
  ("x", int cell.x),
  ("y", int cell.y),
  ("note", string cell.note),
  ("color", string cell.color),
  ("symbol", string cell.symbol)
  ]

jWalls : Set Wall -> ENC.Value
jWalls walls =
  let
    wallList = Set.toList walls
    wallArr = List.map (\wa ->
      case wa of
        [xs, xe, ys, ye] -> list [int xs, int xe, int ys, int ye]
        _ -> list [int -1, int -1, int -1, int -1]) wallList
  in
    list wallArr

jRobits : List Robit -> ENC.Value
jRobits robits = list <| List.map jRobit robits

jRobit : Robit -> ENC.Value
jRobit robit =
  let
    x = fst robit.coords
    y = snd robit.coords
  in
  object [
    ("color", string robit.color),
    ("coords", list [int x, int y])
  ]

jActiveCells : Set (Int, Int) -> ENC.Value
jActiveCells theCells =
  let
    tuple2ToList tc = list [int (fst tc), int (snd tc)]
  in
    list <| List.map tuple2ToList <| Set.toList theCells
