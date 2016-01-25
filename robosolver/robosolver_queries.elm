module RobosolverQueries where
{-| RobosolverQueries

# Types
@docs coordsMatch, findCell, inActiveCells, wallCoordsMatch, wallForDir, wallOnCellSide
-}
import Set
import Dict
import RobosolverTypes exposing (Wall, Cell, Coords, Model)

{-| wallCoordsMatch -}
wallCoordsMatch : Wall -> Wall -> Bool
wallCoordsMatch a b = a == b -- hopefully that's good enough?

{-| coordsMatch -}
coordsMatch : Cell -> Cell -> Bool
coordsMatch a b = a.x == b.x && a.y == b.y

{-| inActiveCells -}
inActiveCells : Cell -> Model -> Bool
inActiveCells cell model =
    Set.member (cell.x, cell.y) model.activeCells

{-| findCell -}
findCell : Coords -> Model -> Maybe Cell
findCell coords model =
  Dict.get coords model.board.cells

{-| wallOnCellSide -}
wallOnCellSide : Model -> Cell -> String -> Bool
wallOnCellSide model cell direction =
  let
    wall = wallForDir (cell.x, cell.y) direction
  in
    Set.member wall model.board.walls

{-| wallForDir -}
wallForDir : Coords -> String -> Wall
wallForDir simpleCell direction =
  let
      x = fst simpleCell
      y = snd simpleCell
  in
    case direction of
      "left" -> [x - 1, x - 1, y, y + 1]
      "right" -> [x, x, y, y + 1]
      "top" -> [x, x + 1, y, y]
      "bottom" -> [x, x + 1, y + 1, y + 1]
      _ -> [-1, -1, -1, -1]
