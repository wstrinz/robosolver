module RobosolverModel where
import Set exposing (Set)
import RobosolverTypes exposing (Cell, Model, Wall, Action(..), CellOperation(..), Board, Coords, WallObject)
import RobosolverQueries exposing (inActiveCells, wallForDir)

blankWallObj : WallObject
blankWallObj = {startX = -1, endX = -1, startY = -1, endY = -1 }

blankWall : Wall
blankWall = [-1,-1,-1,-1]

makeDummyCell : Int -> Int -> Cell
makeDummyCell x y = { name = "dummy", note = "", x = x, y = y, color = "", symbol = ""}

dummyCell : Cell
dummyCell = { name = "dummy", note = "", x = -1, y = -1, color = "", symbol = "" }

spaceTypes : List (String, String)
spaceTypes = [("",""),
              ("red", "star"),
              ("blue", "gear")]

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
-- objectForWall : Wall -> WallObject
-- objectForWall wall obj =
--   case wall of
--     [Just sx, Just ex, Just sy, Just ey, xs] -> { startX = sx, endX = ex, startY = sy, endY = ex }
--     _ -> blankWallObj

initialX : Int
initialX = 16

initialY : Int
initialY = 16
genWalls = False

initialBoard : Board
initialBoard = { rows = (initializeRows initialX initialY), maxx = initialX, maxy = initialY, walls = initWalls }

initialModel : Model
initialModel = { board = initialBoard, activeCells = Set.empty, isClicking = False }

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

wallsForActiveCells : Model -> String -> Set Wall
wallsForActiveCells model dir =
  Set.map (flip wallForDir <| dir) model.activeCells

update : Action -> Model -> Model
update action model =
  let
    board = model.board
    rows = model.board.rows
    walls = model.board.walls
  in
    case action of
      NoOp -> model
      ResetActiveCells -> { model | activeCells = Set.empty }
      SetClicking val cell ->
        case cell of
          Nothing -> { model | isClicking = val }
          Just c ->
            if (inActiveCells c model)  then
              { model | activeCells = Set.remove (c.x, c.y) model.activeCells,
                        isClicking = val}
            else
              { model | activeCells = Set.insert (c.x, c.y) model.activeCells,
                        isClicking = val }
      CellUpdate operation cell ->
        case operation of
          Nothin -> model
          SetActive ->
            case model.isClicking of
              False -> model
              True ->
                if (inActiveCells cell model)  then
                  { model | activeCells = Set.remove (cell.x, cell.y) model.activeCells }
                else
                  { model | activeCells = Set.insert (cell.x, cell.y) model.activeCells }
          SetNote newNote ->
              { model | board = { board | rows = List.map (updateIfIsCell cell newNote) rows } }
          ToggleWall dir ->
            let
              activeWalls = wallsForActiveCells model dir

              toAdd = Set.diff activeWalls model.board.walls
              toRemove = Set.intersect activeWalls model.board.walls
              newWalls = Set.union (Set.diff model.board.walls toRemove) toAdd
            in
              { model | board = { board | walls = newWalls } }
          SelectType newtype ->
              { model | board = { board | rows = List.map (updateTypeIfIsCell cell newtype ) rows } }
          ClearWalls ->
            let
              activeWalls =
                wallsForActiveCells model "left"
                 |> Set.union  (wallsForActiveCells model "right")
                 |> Set.union  (wallsForActiveCells model "top")
                 |> Set.union  (wallsForActiveCells model "bottom")

              toRemove = Set.intersect model.board.walls activeWalls
              newWalls = Set.diff model.board.walls toRemove
            in
              { model | board = { board | walls = newWalls } }

updateIfIsCell : Cell -> String -> List Cell -> List Cell
updateIfIsCell targetCell newNote currentRow =
  List.map (\cell ->
              if cell.x == targetCell.x && cell.y == targetCell.y then
                {cell | note = newNote}
              else
                cell
                ) currentRow

updateTypeIfIsCell : Cell -> (String, String) -> List Cell -> List Cell
updateTypeIfIsCell targetCell newtype currentRow =
  List.map (\cell ->
              if cell.x == targetCell.x && cell.y == targetCell.y then
                {cell | color = fst newtype,
                        symbol = snd newtype}
              else
                cell
                ) currentRow
