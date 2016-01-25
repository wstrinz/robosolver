module RobosolverInits (initialModel, initCell, blankModel) where
{-| Robosolver Inits

# Types
@docs initialModel, initCell, blankModel
-}
import Set exposing (Set)
import Dict exposing (Dict)
import RobosolverTypes exposing (..)

initialX : Int
initialX = 16

initialY : Int
initialY = 16
genWalls = False

initialBoard : Board
initialBoard = { cells = (initializeCells initialX initialY),
                 maxx = initialX, maxy = initialY,
                 walls = initWalls,
                 robits = initRobits }

{-| dummy model -}
initialModel : Model
initialModel = { board = initialBoard, activeCells = Set.empty, isClicking = False }

{-| dummy model -}
blankModel : Model
blankModel = { board = blankBoard, activeCells = Set.empty, isClicking = False }

blankBoard : Board
blankBoard = { cells = (initializeCells initialX initialY),
                 maxx = initialX, maxy = initialY,
                 walls = Set.empty,
                 robits = [] }


initRobits : List Robit
initRobits = [{color = "red", coords = (1, 1)},
             {color = "blue", coords = (5, 5)},
             {color = "yellow", coords = (8,8)}]

initWalls : Set Wall
initWalls = Set.fromList [[2,2,1,2],[3,3,4,5],[2,3,2,2],[1,2,1,1]]

initializeCells : Int -> Int -> CellDict
initializeCells x y = cellMap x y

cellMap : Int -> Int -> CellDict
cellMap width height =
    let
      thisRow yo = createRow  yo
    in
      Dict.fromList
        <| List.foldl (::) []
        <| List.concat
        <| List.map (createRow width) [1..height]

createRow : Int -> Int -> List (Coords, Cell)
createRow width yCoord =
  let
    -- dFoldFun coords cell dict =
    --   Dict.union (cellEntry coords cell) dict
    genColEntry = flip createMappedCell <| yCoord
  in
    List.map genColEntry [1..width]

createMappedCell : Int -> Int -> ((Int, Int), Cell)
createMappedCell y x = ((x,y), (initCell y x))


-- dict.insert 2 "lo" d
-- dict.fromlist [(1,"hi"),(2,"lo")] : dict.dict number string
-- > a = array.fromlist [(1, "hi"), (2, "lo"),(3, "g")]
-- array.fromlist [(1,"hi"),(2,"lo"),(3,"g")] : array.array ( number, string )
-- > array.foldl
-- <function: foldl> : (a -> b -> b) -> b -> array.array a -> b
-- > array.foldl (\val dic -> dict.insert (fst val) (snd val) dic) d a

initRow : Int -> Int -> List Cell
initRow length y = List.map (initCell y) [1..length]

genSingleton : Int -> Int -> CellDict
genSingleton x y = Dict.singleton (x,y) (initCell x y)

{-| initCell -}
initCell : Int -> Int -> Cell
initCell y x =
      { name = "c",
        x = x, y = y,
        note = "",
        color = "",
        symbol = "" }

{-| badCell -}
badCell : Int -> Int -> Cell
badCell y x =
      { name = "x",
        x = x, y = y,
        note = "bad",
        color = "beige",
        symbol = "" }
