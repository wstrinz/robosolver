module RobosolverTypes where
import Set exposing (Set, singleton)

type alias Coords = (Int, Int)
type alias Model = { board: Board, activeCells: Set (Int, Int), isClicking: Bool }
type alias Board = { maxx: Int, maxy: Int, rows: List (List Cell), walls: Set Wall }

type alias Cell = { name: String, x: Int, y: Int, note: String }

type alias Wall = List Int
type alias WallObject = { startX: Int, endX: Int, startY: Int, endY: Int }

type CellOperation =
  Nothin
    | SetActive
    | SetNote String
    | ToggleWall String
    | ClearWalls

type Action =
  NoOp
    | ResetActiveCells
    | SetClicking Bool (Maybe Cell)
    | CellUpdate CellOperation Cell
