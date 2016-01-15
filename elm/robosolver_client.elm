module RobosolverClient where
import Html exposing (Html, div, text, button, p, br)
import Html.Attributes exposing (src, attribute)
import Html.Events exposing (onClick)
import Signal -- exposing (Html)
import List exposing (map)

-- type alias Model = { currentSong: String, loaded: Bool, position: Float, state: String, trackList: TrackList }
type alias Model = { board: Board }
type alias Board = { maxx: Int, maxy: Int, rows: List (List Cell) }

type alias Cell = { name: String, x: Int, y: Int, note: String }

initialCell : Cell
initialCell = { name = "A", x = 0, y = 0, note = "" }

initialCell2 : Cell
initialCell2 = { name = "B", x = 1, y = 0, note = "" }

otherCell : Cell
otherCell = { name = "C", x = 0, y = 1, note = "" }

otherCell2 : Cell
otherCell2 = { name = "D", x = 1, y = 1, note = "" }

initialBoard : Board
initialBoard = { rows = [[initialCell, initialCell2],[otherCell, otherCell2]], maxx = 2, maxy = 2   }
initialModel : Model
initialModel = { board = initialBoard }

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
    Html.table [] (cellsDiv address model)
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
          button [ onClick address (CellUpdate (SetNote "x") cell)] [ text "Update" ]
         ]

cellDesc : Cell -> String
cellDesc cell = (cell.name ++ "_" ++ (toString cell.x) ++ "_" ++ (toString cell.y) ++ "_" ++ cell.note)
-- port playSong : Signal String
-- port playSong = Signal.map toString playerActions.signal

-- port songPos : Signal Float

-- port trackList : Signal (List String)
