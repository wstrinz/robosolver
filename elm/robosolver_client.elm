module RobosolverClient where
import Html exposing (Html, div, text, button, p, br)
import Html.Attributes exposing (src, attribute, style)
import Html.Events exposing (onClick)
import Signal -- exposing (Html)
import List exposing (map)

type alias Model = { board: Board }
type alias Board = { maxx: Int, maxy: Int, rows: List (List Cell) }

type alias Cell = { name: String, x: Int, y: Int, note: String }

initialX = 10
initialY = 10
initialBoard : Board
initialBoard = { rows = (initializeRows initialX initialY), maxx = initialX, maxy = initialY }

initialModel : Model
initialModel = { board = initialBoard }

initializeRows : Int -> Int -> List (List Cell)
initializeRows x y = List.map (initRow x) [1..y]

initRow : Int -> Int -> List Cell
initRow length y = List.map (initCell y) [1..length]

initCell : Int -> Int -> Cell
initCell y x = { name = ("C"++(toString x)++"_"++(toString y)), x = x, y = y, note = "" }

type CellOperation =
  Nothin
    | SetNote String

type Action =
  NoOp
    | CellUpdate CellOperation Cell


actions : Signal.Mailbox Action
actions = Signal.mailbox NoOp

model : Signal Model
model = Signal.foldp update initialModel actions.signal

main : Signal Html.Html
main = Signal.map (view actions.address) model

update : Action -> Model -> Model
update action model =
  let
    board = model.board
    rows = model.board.rows
  in
    case action of
      NoOp -> model
      CellUpdate operation cell ->
        case operation of
          Nothin -> model
          SetNote newNote ->
              { model | board = { board | rows = List.map (updateIfIsCell cell newNote) rows } }

updateIfIsCell : Cell -> String -> List Cell -> List Cell
updateIfIsCell targetCell newNote currentRow =
  List.map (\cell ->
              if cell == targetCell then
                {cell | note = newNote}
              else
                cell
                ) currentRow

view : Signal.Address Action -> Model -> Html.Html
view address model = div [] [
    p [] [text (toString model.board)],
    Html.table [style [("border", "solid 1px black")]] (cellsDiv address model)
  ]


cellsDiv : Signal.Address Action -> Model -> List Html
cellsDiv address model =
  List.map (cellRow address) model.board.rows

cellRow : Signal.Address Action -> List Cell -> Html.Html
cellRow address row = Html.tr [] (List.map (cellCol address) row)

cellCol : Signal.Address Action -> Cell -> Html.Html
cellCol address cell =
 Html.td [] [
          p [] [text (cellDesc cell)],
          button [ onClick address (CellUpdate (SetNote "x") cell)] [ text "x" ]
         ]

cellDesc : Cell -> String
cellDesc cell = (cell.name ++ "_" ++ (toString cell.x) ++ "_" ++ (toString cell.y) ++ "_" ++ cell.note)

-- port playSong : Signal String
-- port playSong = Signal.map toString playerActions.signal

-- port songPos : Signal Float
