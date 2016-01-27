module RobosolverModel (model, actions, entityTypes, spaceTypes, reachableCells) where
{-| RobosolverModel

# Types
@docs model, actions, entityTypes, spaceTypes, reachableCells
-}
import Set exposing (Set)
import Dict exposing (Dict)
import RobosolverEncoder exposing (modelToJson)
import RobosolverDecoder exposing (maybeModelFromJson)
import RobosolverTypes exposing (Cell, Model, Wall, Action(..), CellOperation(..), Board, Coords, Robit)
import RobosolverInits exposing (initialModel, blankModel, initCell)
import RobosolverQueries exposing (inActiveCells, wallForDir, findCell)
import RobosolverUpdateHandler exposing (update)

blankWall : Wall
blankWall = [-1,-1,-1,-1]

makeDummyCell : Int -> Int -> Cell
makeDummyCell x y = { name = "dummy", note = "", x = x, y = y, color = "", symbol = ""}

dummyCell : Cell
dummyCell = { name = "dummy", note = "", x = -1, y = -1, color = "", symbol = "" }

{-| spaceTypes -}
spaceTypes : List (String, String)
spaceTypes = [("",""),
              ("red", "star"),
              ("red", "moon"),
              ("red", "gear"),
              ("red", "planet"),
              ("yellow", "star"),
              ("yellow", "moon"),
              ("yellow", "gear"),
              ("yellow", "planet"),
              ("blue", "star"),
              ("blue", "moon"),
              ("blue", "planet"),
              ("blue", "gear"),
              ("green", "star"),
              ("green", "moon"),
              ("green", "planet"),
              ("green", "gear"),
              ("purple", "wild")]

{-| entityTypes -}
entityTypes : List (String, String)
entityTypes = [("",""),
              ("red", "robot"),
              ("green", "robot"),
              ("yellow", "robot"),
              ("blue", "robot")]

cellForCoords : Coords -> Cell
cellForCoords coords =
  case coords of
    (x, y) -> makeDummyCell x y

{-| actions -}
actions : Signal.Mailbox Action
actions = Signal.mailbox NoOp

{-| model -}
model : Signal Model
model = Signal.foldp update initialModel <| Signal.merge actions.signal <| Signal.map loadStringAction loadModel

loadStringAction : (Int, String) -> Action
loadStringAction msg =
   let
     version = fst msg
     str = snd msg
   in
     case version of
       0 -> LoadModel (RobosolverDecoder.decodeLegacyModel str)
       _ -> LoadModel (RobosolverDecoder.modelFromJson str)


cellFindWithDefault : Int -> Model -> Int -> Cell
cellFindWithDefault y model x =
 case findCell (x, y) model of
   Just c -> c
   _ -> initCell -1 -1

cellToLeft : Int -> Int -> Model -> List Cell
cellToLeft rowLength y model =
    List.map (cellFindWithDefault y model) [1..rowLength]

cellToRight : Int -> Int -> Model -> List Cell
cellToRight rowLength y model =
    List.map (cellFindWithDefault y model) [rowLength..(model.board.maxx)]

hasWallInDir : String -> Model -> Cell -> Bool
hasWallInDir dir m c =
  Set.member (wallForDir (c.x, c.y) dir) m.board.walls

{-| cells wot can be reached -}
reachableCells : Model -> Cell -> List Cell
reachableCells m cell =
  let
    leftMoves =
      List.filter (hasWallInDir "left" m) (cellToLeft cell.x cell.y m)
    rightMoves =
      List.filter (hasWallInDir "right" m) (cellToRight cell.x cell.y m)
    leftMove = case List.head (List.reverse leftMoves) of
      Just c -> c
      _ -> initCell -1 -1
    rightMove = case List.head rightMoves of
      Just c -> c
      _ -> initCell -1 -1
  in
     [leftMove, rightMove]

port loadModel : Signal (Int, String)

port fetchModel : Signal String
port fetchModel = Signal.map toString actions.signal

port saveModel : Signal (String, Bool)
port saveModel = Signal.map (\act ->
                                case act of
                                  SaveModel model -> (modelToJson model, True)
                                  _ -> ("", False)) actions.signal
