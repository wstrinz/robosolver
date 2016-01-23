module RobosolverDecoder where
import Set exposing (Set)
import Json.Decode as DEC exposing (int, string, Decoder, (:=), bool)
import Json.Decode.Extra as DECE
import RobosolverInits exposing (initialModel)
import RobosolverTypes exposing (..)

maybeModelFromJson : String -> Maybe Model
maybeModelFromJson json =
  case (DEC.decodeString modelDecoder json) of
    Result.Ok model -> Just model
    Result.Err errStr -> Nothing


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
