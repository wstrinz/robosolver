module RobosolverInits where
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

initialModel : Model
initialModel = { board = initialBoard, activeCells = Set.empty, isClicking = False }

initRobits : List Robit
initRobits = [{color = "red", coords = (1, 1)},
             {color = "blue", coords = (5, 5)},
             {color = "yellow", coords = (8,8)}]

initWalls : Set Wall
initWalls = Set.fromList [[2,2,1,2],[3,3,4,5],[2,3,2,2],[1,2,1,1]]

initializeCells : Int -> Int -> Dict (Int, Int) Cell
initializeCells x y = cellMap x y

cellMap : Int -> Int -> Dict (Int, Int) Cell
cellMap x y =
    let
      thisRow yo = createRow x yo
    in
      Dict.fromList
        <| List.foldl (::) [] (List.map (createMappedCell x) [1..y])

createRow : Int -> Int -> Dict (Int, Int) Cell
createRow x y = Dict.singleton (x, y) (initCell x y)

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

initCell : Int -> Int -> Cell
initCell y x =
      { name = "c",
        x = x, y = y,
        note = "",
        color = "",
        symbol = "" }
