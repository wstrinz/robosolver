module RobosolverInits where
import Set exposing (Set)
import RobosolverTypes exposing (..)

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
