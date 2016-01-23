module RobosolverEncoder where
import Set exposing (Set)
import Json.Encode as ENC exposing (string, int, object, list)
import RobosolverTypes exposing (..)

modelToJson : Model -> String
modelToJson model = ENC.encode 0 (jModel model)

jModel : Model -> ENC.Value
jModel model = object [
    ("board", jBoard model.board),
    ("activeCells", jActiveCells model.activeCells)
  ]

jBoard : Board -> ENC.Value
jBoard board = object [
    ("maxx", int board.maxx),
    ("maxy", int board.maxy),
    ("rows", jRows board.rows),
    ("walls", jWalls board.walls),
    ("robits", jRobits board.robits)
  ]

jRows : List (List Cell) -> ENC.Value
jRows rows = list <| List.map jCells rows

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
jRobits robits =
   list <| List.map jRobit robits

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
    clist = Set.toList theCells
    realList = List.map (\tc -> list [int (fst tc), int (snd tc)]) clist
  in
    list realList
