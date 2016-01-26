module RobosolverUpdateHandler (update) where
{-| Robosolver Updater

# Types
@docs update
-}
import Debug
import Dict exposing (Dict)
import Set exposing (Set)
import Task exposing (andThen)
import RobosolverTypes exposing (..)
import RobosolverDecoder exposing (modelFromJson)
import RobosolverQueries as Queries
-- import RobosolverPersistence exposing (saveModel, loadModel)

{-| update -}
update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    ResetActiveCells -> { model | activeCells = Set.empty }
    SetClicking val cell -> setClicking val cell model
    CellUpdate operation cell -> cellUpdate operation cell model
    SaveModel model -> model
    LoadModel newModel -> loadModel newModel model
    FetchModel -> model
    FetchBasicModel -> model


loadModel : Model -> Model -> Model
loadModel newModel model =
  {model | board = newModel.board,
           activeCells = newModel.activeCells }

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
    cells = model.board.cells
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
          { model | board = { board | cells = updateCellNote cell cells newNote } }
      ToggleWall dir ->
        let
          activeWalls = wallsForActiveCells model dir

          toAdd = Set.diff activeWalls model.board.walls
          toRemove = Set.intersect activeWalls model.board.walls
          newWalls = Set.union (Set.diff model.board.walls toRemove) toAdd
        in
          { model | board = { board | walls = newWalls } }
      SelectType newtype ->
          { model | board = { board | cells = updateCellType cell cells newtype } }
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

updateCellNote : Cell -> CellDict -> String -> CellDict
updateCellNote cell dict newNote =
  Dict.insert (cell.x, cell.y) { cell | note = newNote} dict
  
updateCellType : Cell -> CellDict -> (String, String) -> CellDict
updateCellType cell dict newType =
  Dict.insert (cell.x, cell.y) {cell | color = fst newType,
                                       symbol = snd newType} dict

wallsForActiveCells : Model -> String -> Set Wall
wallsForActiveCells model dir =
  Set.map (flip Queries.wallForDir <| dir) model.activeCells
