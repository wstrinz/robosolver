module RobosolverDecoder (modelFromJson, maybeModelFromJson, decodeLegacyModel) where
{-| Robosolver Decoder

# Types
@docs modelFromJson, maybeModelFromJson, decodeLegacyModel
-}
import Set exposing (Set)
import Dict exposing (Dict)
import Json.Decode as DEC exposing (int, string, Decoder, (:=), bool)
import Json.Decode.Extra as DECE
import RobosolverInits exposing (initialModel, blankModel)
import RobosolverTypes exposing (..)

{- Model aliases w/ lists, because dicts are hard -}
type alias ListBoard = { maxx: Int, maxy: Int, cells: List Cell, walls: Set Wall, robits: List Robit }
type alias ListModel = { board: ListBoard, activeCells: Set (Int, Int), isClicking: Bool }

{-| convert model, return nothing if fails -}
maybeModelFromJson : String -> Maybe Model
maybeModelFromJson json =
  case (DEC.decodeString modelDecoder json) of
    Result.Ok model -> Just <| modelFromListModel model
    Result.Err errStr -> Nothing

{-| convert model -}
modelFromJson : String -> Model
modelFromJson json =
  case (DEC.decodeString modelDecoder json) of
    Result.Ok model -> modelFromListModel model
    Result.Err errStr -> Debug.log ("parse error " ++ errStr ++ " \n") initialModel

modelFromListModel : ListModel -> Model
modelFromListModel model =
  let
    board = model.board
    listToDict cellList =
      Dict.fromList <| List.map (\c -> ((c.x, c.y), c)) cellList
  in
    {model | board = { board | cells = listToDict model.board.cells} }

modelDecoder : Decoder ListModel
modelDecoder =
  DEC.object3 ListModel
    ("board" := boardDec )
    ("activeCells" := activeCellsDec )
    ("isClicking" := bool )

boardDec : Decoder ListBoard
boardDec =
  DEC.object5 ListBoard
    ("maxx" := int)
    ("maxy" := int)
    ("cells" := (DEC.list cellDec) )
    ("walls" := wallsDec)
    ("robits" := (DEC.list robitDec) )

robitsDec : Decoder (List Robit)
robitsDec = DEC.list robitDec

wallsDec : Decoder (Set Wall)
wallsDec = DECE.set <| DEC.list int

robitDec : Decoder Robit
robitDec =
  DEC.object2 Robit
    ("color" := string)
    ("coords" := DEC.tuple2 (,) int int)

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

-- Legacy decoders; pointless but kind of an experiment
{-| outward facing legacy decorder -}
decodeLegacyModel : String -> Model
decodeLegacyModel json =
  let
    maybeModel = modelFromLegacyJson json

  in
    case maybeModel of
      Just m -> legacyToCurrent m
      _ -> blankModel

legacyBoardToCurrent : LegacyBoard -> Board
legacyBoardToCurrent legBoard =
  let
    board = legBoard
    convertedRow row =
      List.map (\c -> ((c.x, c.y), c)) row
    rowsToCells =
      List.concat <| List.map convertedRow board.rows
  in
    {
      maxx = board.maxx,
      maxy = board.maxy,
      robits = board.robits,
      cells = (Dict.fromList rowsToCells),
      walls = board.walls
    }

{-| convert old model -}
legacyToCurrent : LegacyModel -> Model
legacyToCurrent model =
  { board = legacyBoardToCurrent model.board,
    activeCells = model.activeCells,
    isClicking = model.isClicking }

{-| legacy converter -}
modelFromLegacyJson : String -> Maybe LegacyModel
modelFromLegacyJson json =
  case (DEC.decodeString legacyModelDecoder json) of
    Result.Ok m -> Just m
    Result.Err errStr -> Debug.log ("parse error" ++ errStr) Nothing

legacyModelDecoder : Decoder LegacyModel
legacyModelDecoder =
  DEC.object3 LegacyModel
    ("board" := legacyBoardDec )
    ("activeCells" := activeCellsDec )
    ("isClicking" := bool )

legacyBoardDec : Decoder LegacyBoard
legacyBoardDec =
  DEC.object5 LegacyBoard
    ("maxx" := int)
    ("maxy" := int)
    ("rows" := (DEC.list <| DEC.list cellDec) )
    ("walls" := wallsDec )
    ("robits" := robitsDec )
