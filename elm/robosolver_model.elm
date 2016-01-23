module RobosolverModel where
import Set exposing (Set)
import RobosolverTypes exposing (Cell, Model, Wall, Action(..), CellOperation(..), Board, Coords, Robit)
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

initialX : Int
initialX = 16

initialY : Int
initialY = 16
genWalls = False

initialBoard : Board
initialBoard = { rows = (initializeRows initialX initialY), maxx = initialX, maxy = initialY, walls = initWalls, robits = initRobits }

initialModel : Model
initialModel = { board = initialBoard, activeCells = Set.empty, isClicking = False }

initRobits : List Robit
initRobits = [{color = "red", coords = (1, 1)},
             {color = "blue", coords = (5, 5)},
             {color = "yellow", coords = (8,8)}]

initWalls : Set Wall
initWalls = Set.fromList [[2,2,1,2],[3,3,4,5],[2,3,2,2],[1,2,1,1]]

initializeRows : Int -> Int -> List (List Cell)
initializeRows x y = List.map (initRow x) [1..y]

initRow : Int -> Int -> List Cell
initRow length y = List.map (initCell y) [1..length]

initCell : Int -> Int -> Cell
initCell y x =
      { name = "c",
        x = x, y = y,
        note = "",
        color = "",
        symbol = "" }

actions : Signal.Mailbox Action
actions = Signal.mailbox NoOp

model : Signal Model
model = Signal.foldp update initialModel actions.signal
