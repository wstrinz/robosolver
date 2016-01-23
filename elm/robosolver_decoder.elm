module RobosolverDecoder where
import Set exposing (Set)
import Json.Decode as DEC exposing (int, string, Decoder, (:=), bool)
import Json.Decode.Extra as DECE
import RobosolverModel exposing (initialModel)
import RobosolverTypes exposing (..)

modelFromJson : String -> Model
modelFromJson json =
  case (DEC.decodeString modelDecoder json) of
    Result.Ok model -> model
    Result.Err errStr -> initialModel

modelDecoder : Decoder Model
modelDecoder =
  DEC.object3 Model
    ("board" := boardDec )
    ("activeCells" := activeCellsDec)
    ("isClicking" := bool )

boardDec : Decoder Board
boardDec =
  DEC.object5 Board
    ("maxx" := int)
    ("maxy" := int)
    ("rows" := rowsDec )
    ("walls" := wallsDec )
    ("robits" := robitsDec )

robitsDec : Decoder (List Robit)
robitsDec = DEC.list robitDec

robitDec : Decoder Robit
robitDec =
  DEC.object2 Robit
    ("color" := string)
    ("coords" := DEC.tuple2 (,) int int)

wallsDec : Decoder (Set Wall)
wallsDec = DECE.set wallDec

wallDec : Decoder Wall
wallDec = DEC.list int

rowsDec : Decoder (List (List Cell))
rowsDec = DEC.list rowDec

rowDec : Decoder (List Cell)
rowDec = DEC.list cellDec

cellDec : Decoder Cell
cellDec =
  DEC.object6 Cell
    ("name" := string)
    ("x" := int)
    ("y" := int)
    ("note" := string)
    ("color" := string)
    ("symbol" := string)

activeCellsDec : Decoder (Set (Int, Int))
activeCellsDec =
  DECE.set pointDec

pointDec : Decoder (Int, Int)
pointDec =
  DEC.tuple2 (,) int int

-- jModel : Model -> ENC.Value
-- jModel model = object [
--     ("board", jBoard model.board),
--     ("activeCells", jActiveCells model.activeCells)
--   ]
--
-- jBoard : Board -> ENC.Value
-- jBoard board = object [
--     ("maxx", int board.maxx),
--     ("maxy", int board.maxy),
--     ("rows", jRows board.rows),
--     ("walls", jWalls board.walls),
--     ("robits", jRobits board.robits)
--   ]
--
-- jRows : List (List Cell) -> ENC.Value
-- jRows rows = list <| List.map jCells rows
--
-- jCells : List Cell -> ENC.Value
-- jCells cells = list <| List.map jCell cells
--
-- jCell : Cell -> ENC.Value
-- jCell cell = object [
--   ("name", string cell.name),
--   ("x", int cell.x),
--   ("y", int cell.y),
--   ("note", string cell.note),
--   ("color", string cell.color),
--   ("symbol", string cell.symbol)
--   ]
--
-- jWalls : Set Wall -> ENC.Value
-- jWalls walls =
--   let
--     wallList = Set.toList walls
--
--     listOfEncWalls wall =
--       list <| List.map int wall
--   in
--     list <| List.map listOfEncWalls wallList
--
-- jRobits : List Robit -> ENC.Value
-- jRobits robits = list <| List.map jRobit robits
--
-- jRobit : Robit -> ENC.Value
-- jRobit robit =
--   let
--     x = fst robit.coords
--     y = snd robit.coords
--   in
--   object [
--     ("color", string robit.color),
--     ("coords", list [int x, int y])
--   ]
--
-- jActiveCells : Set (Int, Int) -> ENC.Value
-- jActiveCells cellSet =
--   let
--     cellList = List.map (\c -> [fst c, snd c]) (Set.toList cellSet)
--   in
--     list <| List.map int cellList
--
-- modelToJson : Model -> String
-- modelToJson model = ENC.encode 0 (jModel model)

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
