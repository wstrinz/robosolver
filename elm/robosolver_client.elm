module RobosolverClient where
import Html exposing (Html, div, text, button, p, br)
import Html.Attributes exposing (src, attribute)
import Html.Events exposing (onClick)
import Signal -- exposing (Html)
import List exposing (map)

-- type alias Model = { currentSong: String, loaded: Bool, position: Float, state: String, trackList: TrackList }
type alias Model = { board: List (Cell) }

type alias Cell = { name: String, x: Int, y: Int, note: String }

initialCell : Cell
initialCell = { name = "AnCell", x = 1, y = 2, note="" }

initialModel : Model
initialModel = { board = [initialCell] }

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
  case action of
    NoOp -> model
    CellUpdate operation cell ->
      case operation of
        Nothin -> model
        SetNote newNote -> { model | board = [updateCellNote cell newNote] }

updateCellNote : Cell -> String -> Cell
updateCellNote oldCell newNote =
   {oldCell | note = newNote}
   -- {name = oldCell.name, x = oldCell.x, y = oldCell.y, note = newNote}


view : Signal.Address Action -> Model -> Html.Html
view address model = div [] [
  p [] [text (toString model.board)],
  cellsDiv address model
  ]


cellsDiv : Signal.Address Action -> Model -> Html.Html
cellsDiv address model =
  div [] (List.map (cellDiv address) model.board)

cellDiv : Signal.Address Action -> Cell -> Html.Html
cellDiv address cell =
  div [] [
          p [] [text (cell.name ++ "_" ++ (toString cell.x) ++ "_" ++ (toString cell.y))],
          button [ onClick address (CellUpdate (SetNote "Lol") cell)] [ text "Update" ]
         ]

-- port playSong : Signal String
-- port playSong = Signal.map toString playerActions.signal

-- port songPos : Signal Float

-- port trackList : Signal (List String)
