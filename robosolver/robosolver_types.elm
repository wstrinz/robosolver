module RobosolverTypes where
{-| RobosolverTypes

# Types
@docs Board, Cell, Coords, MappedCell, Model, Robit, Wall,
      WallObject, Action, CellOperation, CellDict,
      LegacyModel, LegacyBoard, Direction, WallShape
-}
import Set exposing (Set, singleton)
import Dict exposing (Dict, singleton)

{-| Wall -}
type alias Wall = (WallShape, String)

{-| WallShape -}
type alias WallShape = (Int, Int, Int, Int)


{-| WallObject -}
type alias WallObject = { startX: Int, endX: Int, startY: Int, endY: Int }
{-| Coords -}
type alias Coords = (Int, Int)
{-| Robit -}
type alias Robit = { color: String, coords: Coords }
{-| CellDict -}
type alias CellDict = Dict (Int, Int) Cell
{-| Cell -}
type alias Cell = { name: String, x: Int, y: Int, note: String, color: String, symbol: String }
{-| Board -}
type alias Board = { maxx: Int, maxy: Int, cells: CellDict, walls: Set Wall, robits: List Robit }
{-| Model -}
type alias Model = { board: Board, activeCells: Set (Int, Int), isClicking: Bool }
{-| MappedCell -}
type alias MappedCell = ((Int, Int), Cell)
--
{-| CellOperation -}
type CellOperation =
  Nothin
    | SetActive
    | SetNote String
    | ToggleWall String
    | ClearWalls
    | SelectType (String, String)
    | SetEntity String

{-| Action -}
type Action =
  NoOp
    | ResetActiveCells
    | SaveModel Model
    | LoadModel Model
    | FetchModel
    | FetchBasicModel
    | SetClicking Bool (Maybe Cell)
    | CellUpdate CellOperation Cell

{-| Direction -}
type Direction =
  Left
    | Right
    | Top
    | Bottom

{-| WallColor -}
-- type WallColor =
--   Black
--     | Yellow
--     | Green
--     | Blue
--     | Red

-- 'Legacy' types

{-| LegacyModel -}
type alias LegacyBoard = { maxx: Int, maxy: Int, rows: List (List Cell), walls: List (List Int), robits: List Robit }
{-| LegacyBoard -}
type alias LegacyModel = { board: LegacyBoard, activeCells: Set (Int, Int), isClicking: Bool }
