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

{-| convert model, return nothing if fails -}
maybeModelFromJson : String -> Maybe Model
maybeModelFromJson json =
  case (DEC.decodeString modelDecoder json) of
    Result.Ok model -> Just model
    Result.Err errStr -> Nothing

{-| convert model -}
modelFromJson : String -> Model
modelFromJson json =
  case (DEC.decodeString modelDecoder json) of
    Result.Ok model -> model
    Result.Err errStr -> Debug.log ("parse error " ++ errStr ++ " \n") initialModel

modelDecoder : Decoder Model
modelDecoder =
  DEC.object3 Model
    ("board" := boardDec )
    ("activeCells" := activeCellsDec )
    ("isClicking" := bool )

boardDec : Decoder Board
boardDec =
  DEC.object5 Board
    ("maxx" := int)
    ("maxy" := int)
    ("cells" := cellsDec )
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

cellsDec : Decoder (Dict (Int, Int) Cell)
cellsDec = DECE.dict2 pointDec cellDec

cellEntriesDec : Decoder ((Int, Int), Cell)
cellEntriesDec =
  cellDec `DEC.andThen` cellWithCoords

cellWithCoords : Cell -> Decoder ((Int, Int), Cell)
cellWithCoords cell =
  DEC.tuple2 (,) pointDec cellDec

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
