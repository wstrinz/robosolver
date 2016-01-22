module RobosolverQueries where
import Set
import RobosolverTypes exposing (Wall, Cell, Coords, Model)

wallCoordsMatch : Wall -> Wall -> Bool
wallCoordsMatch a b = a == b -- hopefully that's good enough?

coordsMatch : Cell -> Cell -> Bool
coordsMatch a b = a.x == b.x && a.y == b.y

inActiveCells : Cell -> Model -> Bool
inActiveCells cell model =
    Set.member (cell.x, cell.y) model.activeCells

findCell : Coords -> Model -> Maybe Cell
findCell coords model =
  let
    found = List.head
              <| List.filter (\cell -> coords == (cell.x, cell.y))
              <| List.concat model.board.rows
  in
    found


wallOnCellSide : Model -> Cell -> String -> Bool
wallOnCellSide model cell direction =
  Set.member (wallForDir (cell.x, cell.y) direction) model.board.walls

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
