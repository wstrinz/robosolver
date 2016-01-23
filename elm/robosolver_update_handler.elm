module RobosolverUpdateHandler where
import Set exposing (Set)
import Task exposing (andThen)
import RobosolverTypes exposing (..)
import RobosolverDecoder exposing (modelFromJson)
import RobosolverQueries as Queries
-- import RobosolverPersistence exposing (saveModel, loadModel)

update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    ResetActiveCells -> { model | activeCells = Set.empty }
    SetClicking val cell -> setClicking val cell model
    CellUpdate operation cell -> cellUpdate operation cell model
    SaveModel model -> model
    LoadModel newModel ->
        {model | board = newModel.board,
                 activeCells = Set.empty}
    FetchModel -> model


setClicking : Bool -> Maybe Cell -> Model -> Model
setClicking val cell model =
  let
    updateCells op c = { model | activeCells = op (c.x, c.y) model.activeCells,
                                 isClicking = val }
  in
  case cell of
    Nothing -> { model | isClicking = val }
    Just c ->
      case (Queries.inActiveCells c model) of
        True -> updateCells (Set.remove) c
        False -> updateCells (Set.insert) c

cellUpdate : CellOperation -> Cell -> Model -> Model
cellUpdate operation cell model =
  let
    board = model.board
    rows = model.board.rows
  in
    case operation of
      Nothin -> model
      SetActive ->
        case model.isClicking of
          False -> model
          True ->
            if (Queries.inActiveCells cell model)  then
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
      SetEntity newEntity ->
          { model | board =
            { board | robits =
              List.map (updateRobitIfTarget newEntity cell) model.board.robits } }
      ClearWalls -> clearWalls model

clearWalls : Model -> Model
clearWalls model =
  let
    board = model.board
    walls = model.board.walls

    activeWalls =
      wallsForActiveCells model "left"
      |> Set.union  (wallsForActiveCells model "right")
      |> Set.union  (wallsForActiveCells model "top")
      |> Set.union  (wallsForActiveCells model "bottom")

    toRemove = Set.intersect model.board.walls activeWalls
    newWalls = Set.diff model.board.walls toRemove
  in
    { model | board = { board | walls = newWalls } }

updateRobitIfTarget : String -> Cell -> Robit -> Robit
updateRobitIfTarget color loc target =
  if color == target.color then
    { color = target.color, coords = (loc.x, loc.y) }
  else
    target

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

wallsForActiveCells : Model -> String -> Set Wall
wallsForActiveCells model dir =
  Set.map (flip Queries.wallForDir <| dir) model.activeCells
