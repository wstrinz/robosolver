module RobosolverClient where
import Html exposing (Html, div, text, button, p, br)
import Html.Attributes exposing (src, attribute, style)
import Html.Events exposing (onClick)
import Signal -- exposing (Html)
import List exposing (map)

type alias Model = { board: Board, activeCell: Maybe Cell }
type alias Board = { maxx: Int, maxy: Int, rows: List (List Cell) }

type alias Cell = { name: String, x: Int, y: Int, note: String, walls: List String }

initialX = 16
initialY = 16

initialBoard : Board
initialBoard = { rows = (initializeRows initialX initialY), maxx = initialX, maxy = initialY }

initialModel : Model
initialModel = { board = initialBoard, activeCell = Nothing }

initializeRows : Int -> Int -> List (List Cell)
initializeRows x y = List.map (initRow x) [1..y]

initRow : Int -> Int -> List Cell
initRow length y = List.map (initCell y) [1..length]

initCell : Int -> Int -> Cell
initCell y x =
    let
      walls =
        -- if x % 3 == 0 then
        --   ["left"]
        -- else if y % 5 == 0 then
        --   ["top"]
        -- else
          []
    in
      { name = "c",
      -- { name = ("c"++(toString x)++"_"++(toString y)),
        x = x, y = y,
        note = "",
        walls = walls }

type CellOperation =
  Nothin
    | SetActive
    | SetNote String
    | ToggleWall String

type Action =
  NoOp
    | CellUpdate CellOperation Cell


-- activeCell : Signal.Mailbox (Maybe Cell)
-- activeCell = Signal.mailbox Nothing

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
          SetActive -> { model | activeCell = Just cell }
          SetNote newNote ->
              { model | board = { board | rows = List.map (updateIfIsCell cell newNote) rows } }
          ToggleWall dir ->
              { model | board = { board | rows = List.map (updateWallsIfCell cell dir) rows } }

updateIfIsCell : Cell -> String -> List Cell -> List Cell
updateIfIsCell targetCell newNote currentRow =
  List.map (\cell ->
              if cell.x == targetCell.x && cell.y == targetCell.y then
                {cell | note = newNote}
              else
                cell
                ) currentRow

updateWallsIfCell : Cell -> String -> List Cell -> List Cell
updateWallsIfCell targetCell wall currentRow =
  List.map (updateWallsIfCellSingular targetCell wall) currentRow

updateWallsIfCellSingular : Cell -> String -> Cell -> Cell
updateWallsIfCellSingular targetCell wall currentCell =
  let
    isMatch = coordsMatch targetCell currentCell
  in
    case isMatch of
      True ->
        if List.member wall currentCell.walls then
          {currentCell | walls = List.filter (\item -> item /= wall) currentCell.walls }
        else
          {currentCell | walls = wall :: currentCell.walls }
      False ->
        currentCell

coordsMatch : Cell -> Cell -> Bool
coordsMatch a b = a.x == b.x && a.y == b.y

view : Signal.Address Action -> Model -> Html.Html
view address model = div [] [
    cellEditor address model,
    Html.table [style [("border", "solid 1px black")]] (cellsDiv address model)
  ]

cellEditor : Signal.Address Action -> Model -> Html.Html
cellEditor address model =
  case model.activeCell of
    Nothing -> div [] [text "(not editing a cell)"]
    Just cell ->
      div [] [
        p [] [text ("editing " ++ (toString cell))],
        div [] [
          p [] [text "Toggle Walls"],
          button [ onClick address (CellUpdate (ToggleWall "left") cell)] [ text "Left" ],
          button [ onClick address (CellUpdate (ToggleWall "right") cell)] [ text "Right" ],
          button [ onClick address (CellUpdate (ToggleWall "top") cell)] [ text "Top" ],
          button [ onClick address (CellUpdate (ToggleWall "bottom") cell)] [ text "Bottom" ]
        ]
      ]

cellsDiv : Signal.Address Action -> Model -> List Html
cellsDiv address model =
  List.map (cellRow address model) model.board.rows

cellRow : Signal.Address Action -> Model -> List Cell -> Html.Html
cellRow address model row = Html.tr [] (List.map (cellCol address model) row)

cellCol : Signal.Address Action -> Model -> Cell -> Html.Html
cellCol address model cell =
 Html.td [style (cellStyle model cell), onClick address (CellUpdate SetActive cell)] [
          p [] [text (cellDesc cell)]
          -- button [ onClick address (CellUpdate (SetNote "o") cell)] [ text "n" ]
         ]

cellStyle : Model -> Cell -> List (String, String)
cellStyle model cell = List.concat([cellWallStyleList cell, cellBgStyleList model cell])

cellWallStyleList : Cell -> List (String, String)
cellWallStyleList cell = List.map (\w -> ("border-" ++ w, "solid 1px black")) cell.walls

cellBgStyleList : Model -> Cell -> List (String, String)
cellBgStyleList model cell =
  case model.activeCell of
    Nothing -> []
    Just aCell ->
      if cell.x == aCell.x && cell.y == aCell.y then
        [("background-color", "aqua")]
      else
        []

cellDesc : Cell -> String
cellDesc cell = (cell.name ++ "_" ++ cell.note)

-- port playSong : Signal String
-- port playSong = Signal.map toString playerActions.signal

-- port songPos : Signal Float
