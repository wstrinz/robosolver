module RobosolverEncoder where
import Set exposing (Set)
import Json.Encode as ENC exposing (string, int, object, list)
import RobosolverTypes exposing (..)

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

    listOfEncWalls wall =
      list <| List.map int wall
  in
    list <| List.map listOfEncWalls wallList

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

jActiveCells cellSet = list []

modelToJson : Model -> String
modelToJson model = ENC.encode 0 (jModel model)

-- modelFromJson : String -> Model
-- modelFromJson json =
--   let decodeResult = Decode.decodeString modelDecoder json
--   in
--     case decodeResult of
--       Result.Ok mod -> modelFromStringy mod
--       Result.Err errStr -> initialModel

-- modelDecoder : Decoder StringyModel
-- modelDecoder =
--   Decode.object4 StringyModel
--     ("counta" := Decode.int)
--     ("countb" := Decode.int)
--     ("page" := Decode.string)
--     ("state" := Decode.string)


