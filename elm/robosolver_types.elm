module RobosolverTypes where
import Set exposing (Set, singleton)
import Dict exposing (Dict, singleton)

type alias Coords = (Int, Int)
type alias Robit = { color: String, coords: Coords }
type alias Model = { board: Board, activeCells: Set (Int, Int), isClicking: Bool }
type alias Board = { maxx: Int, maxy: Int, cells: Dict (Int, Int) Cell, walls: Set Wall, robits: List Robit }

type alias Cell = { name: String, x: Int, y: Int, note: String, color: String, symbol: String }
type alias MappedCell = ((Int, Int), Cell)

type alias Wall = List Int
-- type alias WallObject = { startX: Int, endX: Int, startY: Int, endY: Int }

type CellOperation =
  Nothin
    | SetActive
    | SetNote String
    | ToggleWall String
    | ClearWalls
    | SelectType (String, String)
    | SetEntity String

type Action =
  NoOp
    | ResetActiveCells
    | SaveModel Model
    | LoadModel Model
    | FetchModel
    | FetchBasicModel
    | SetClicking Bool (Maybe Cell)
    | CellUpdate CellOperation Cell
