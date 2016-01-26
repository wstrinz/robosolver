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

cellsToLeftOf : Int -> Int -> Model -> List Cell
cellsToLeftOf rowLength y model =
  let
    toLeftOf xc =
      case findCell (xc, y) model of
        Just c -> c
        _ -> initCell -1 -1
  in
    List.map toLeftOf [1..rowLength]

hasWallInDir : String -> Model -> Cell -> Bool
hasWallInDir dir m c =
  Set.member (wallForDir (c.x, c.y) dir) m.board.walls

{-| cells wot can be reached -}
reachableCells : Model -> Cell -> List Cell
reachableCells m cell =
  let
    leftMoves =
      List.filter (hasWallInDir "left" m) (cellsToLeftOf cell.x cell.y m)
    -- rightMove =
    -- topMove =
    -- bottomMove =
  in
    leftMoves

port loadModel : Signal (Int, String)

port fetchModel : Signal String
port fetchModel = Signal.map toString actions.signal

port saveModel : Signal (String, Bool)
port saveModel = Signal.map (\act ->
                                case act of
                                  SaveModel model -> (modelToJson model, True)
                                  _ -> ("", False)) actions.signal
