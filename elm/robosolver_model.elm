module RobosolverModel where
import Set exposing (Set)
import RobosolverEncoder exposing (modelToJson)
import RobosolverDecoder exposing (maybeModelFromJson)
import RobosolverTypes exposing (Cell, Model, Wall, Action(..), CellOperation(..), Board, Coords, Robit)
import RobosolverInits exposing (initialModel)
import RobosolverQueries exposing (inActiveCells, wallForDir)
import RobosolverUpdateHandler exposing (update)

blankWall : Wall
blankWall = [-1,-1,-1,-1]

makeDummyCell : Int -> Int -> Cell
makeDummyCell x y = { name = "dummy", note = "", x = x, y = y, color = "", symbol = ""}

dummyCell : Cell
dummyCell = { name = "dummy", note = "", x = -1, y = -1, color = "", symbol = "" }

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

actions : Signal.Mailbox Action
actions = Signal.mailbox NoOp

model : Signal Model
model = Signal.foldp update initialModel <| Signal.merge actions.signal <| Signal.map loadStringAction loadModel

loadStringAction : String -> Action
loadStringAction str = LoadModel (RobosolverDecoder.modelFromJson str)

port loadModel : Signal String

port fetchModel : Signal String
port fetchModel = Signal.map toString actions.signal

port saveModel : Signal (String, Bool)
port saveModel = Signal.map (\act ->
                                case act of
                                  SaveModel model -> (modelToJson model, True)
                                  _ -> ("", False)) actions.signal
