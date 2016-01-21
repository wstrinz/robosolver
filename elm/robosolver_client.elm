module RobosolverClient where
import Html exposing (Html, div, text, button, p, br)
import Html.Attributes exposing (src, attribute, style)
import Html.Events exposing (onClick)
import Signal -- exposing (Html)
import List exposing (map , (::))
import Set exposing (Set, singleton)

type alias Coords = (Int, Int)
type alias Model = { board: Board, activeCells: Set (Int, Int), isClicking: Bool }
type alias Board = { maxx: Int, maxy: Int, rows: List (List Cell), walls: List Wall }

type alias Cell = { name: String, x: Int, y: Int, note: String }

type alias Wall = { startX: Int, endX: Int, startY: Int, endY: Int }

initialX : Int
initialX = 16

initialY : Int
initialY = 16
genWalls = False

initialBoard : Board
initialBoard = { rows = (initializeRows initialX initialY), maxx = initialX, maxy = initialY, walls = initWalls }

initialModel : Model
initialModel = { board = initialBoard, activeCells = Set.empty, isClicking = False }

initWalls : List Wall
initWalls = [{startX = 3, startY = 4, endX = 3, endY = 5},
             {startX = 6, startY = 6, endX = 7, endY = 6}]

initializeRows : Int -> Int -> List (List Cell)
initializeRows x y = List.map (initRow x) [1..y]

initRow : Int -> Int -> List Cell
initRow length y = List.map (initCell y) [1..length]

initCell : Int -> Int -> Cell
initCell y x =
      { name = "c",
        x = x, y = y,
        note = "" }
    -- let
      -- walls =
      --   case genWalls of
      --     True ->
      --       if x % 3 == 0 then
      --         singleton "left"
      --       else if y % 5 == 0 then
      --         singleton "top"
      --       else
      --         Set.empty
      --     False ->
      --       Set.empty
    -- in


type CellOperation =
  Nothin
    | SetActive
    | SetNote String
    | ToggleWall String

type Action =
  NoOp
    | ResetActiveCells
    | SetClicking Bool
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
    walls = model.board.walls
  in
    case action of
      NoOp -> model
      ResetActiveCells -> { model | activeCells = Set.empty }
      SetClicking val -> { model | isClicking = val }
      CellUpdate operation cell ->
        case operation of
          Nothin -> model
          SetActive ->
            case model.isClicking of
              False -> model
              True ->
                if (inActiveCells cell model)  then
                  { model | activeCells = Set.remove (cell.x, cell.y) model.activeCells }
                else
                  { model | activeCells = Set.insert (cell.x, cell.y) model.activeCells }
          SetNote newNote ->
              { model | board = { board | rows = List.map (updateIfIsCell cell newNote) rows } }
          ToggleWall dir ->
            let
              toggledWalls = List.map (\c ->
                  case c of
                    Nothing -> {startX = -1, endX = -1, startY = -1, endY = -1 }
                    Just thecell -> (wallForDir thecell dir))
                (List.map (\mc -> findCell mc model)
                  (Set.toList model.activeCells))
              toAdd = List.map (\wa ->
                List.filter (\w -> (not (wallCoordsMatch w wa))) model.board.walls) toggledWalls
            in
              { model | board =
                { board | walls =
                  List.concat (List.append toAdd
                    (List.map (\wa ->
                      List.filter (\w -> (not (wallCoordsMatch w wa))) toggledWalls) model.board.walls))
              } }
              -- if (wallOnCellSide model cell dir) then
              --   { model | board = { board | walls = List.filter (\w -> (not (wallCoordsMatch w newWall))) walls } }
              -- else
              --   { model | board = { board | walls = newWall :: walls } }

                -- { model | board = { board | rows = List.map (updateWallsIfCell model dir) rows } }

updateIfIsCell : Cell -> String -> List Cell -> List Cell
updateIfIsCell targetCell newNote currentRow =
  List.map (\cell ->
              if cell.x == targetCell.x && cell.y == targetCell.y then
                {cell | note = newNote}
              else
                cell
                ) currentRow

updateWallsIfCell : Model -> String -> List Cell -> List Cell
updateWallsIfCell model wall currentRow =
    List.map (updateWallsIfCellSingular model wall) currentRow

updateWallsIfCellSingular : Model -> String -> Cell -> Cell
updateWallsIfCellSingular model wall currentCell =
  currentCell
  -- let
  --   isMatch = inActiveCells currentCell model
  -- in
  --   case isMatch of
  --     True ->
  --       if Set.member wall currentCell.walls then
  --         {currentCell | walls = Set.remove wall currentCell.walls }
  --       else
  --         {currentCell | walls = Set.insert wall currentCell.walls }
  --     False ->
  --       currentCell

wallCoordsMatch : Wall -> Wall -> Bool
wallCoordsMatch a b = a.startX == b.startX && a.startY == b.startY && a.endX == b.endX && a.endY == b.endY

coordsMatch : Cell -> Cell -> Bool
coordsMatch a b = a.x == b.x && a.y == b.y

inActiveCells : Cell -> Model -> Bool
inActiveCells cell model =
    Set.member (cell.x, cell.y) model.activeCells

view : Signal.Address Action -> Model -> Html.Html
view address model = div [Html.Events.onMouseUp address (SetClicking False), style noSelectStyle] [
    button [ onClick address (ResetActiveCells)] [ text "Clear Selection" ],
    Html.table [style [("border", "solid 1px black")]] (cellsDiv address model),
    cellEditor address model
  ]

noSelectStyle = [
  ("-webkit-touch-callout", "none"),
  ("-webkit-user-select", "none"),
  ("-khtml-user-select", "none"),
  ("-moz-user-select", "none"),
  ("-ms-user-select", "none"),
  ("user-select", "none")
  ]

findCell : Coords -> Model -> Maybe Cell
findCell coords model =
  let
    found = List.head (List.filter (\cell -> coords == (cell.x, cell.y)) (List.concat model.board.rows))
  in
    found

cellEditor : Signal.Address Action -> Model -> Html.Html
cellEditor address model =
  let
    firstOfSet = List.head (Set.toList model.activeCells)
    anActiveCell =
      case firstOfSet of
        Nothing -> Nothing
        Just coords -> findCell coords model
  in
  case anActiveCell of
    Nothing -> div [] [text "(not editing a cell)",
                       div [] disabledWallButtons]
    Just cell ->
        div [] [
          p [] (List.map (\thecell -> text ("editing " ++ (toString thecell))) (Set.toList model.activeCells)),
          div [] (realWallButtons address cell)
        ]

realWallButtons : Signal.Address Action -> Cell -> List Html.Html
realWallButtons address cell = [
            p [] [text "Toggle Walls"],
            button [ onClick address (CellUpdate (ToggleWall "left") cell)] [ text "Left" ],
            button [ onClick address (CellUpdate (ToggleWall "right") cell)] [ text "Right" ],
            button [ onClick address (CellUpdate (ToggleWall "top") cell)] [ text "Top" ],
            button [ onClick address (CellUpdate (ToggleWall "bottom") cell)] [ text "Bottom" ],
            Html.select [ ] [ text "red" ]
          ]

disabledWallButtons : List Html.Html
disabledWallButtons =
  [
    p [] [text "Toggle Walls"],
    button [] [ text "Left" ],
    button [] [ text "Right" ],
    button [] [ text "Top" ],
    button [] [ text "Bottom" ]
    ]

cellsDiv : Signal.Address Action -> Model -> List Html
cellsDiv address model =
  List.map (cellRow address model) model.board.rows

cellRow : Signal.Address Action -> Model -> List Cell -> Html.Html
cellRow address model row = Html.tr [] (List.map (cellCol address model) row)

cellCol : Signal.Address Action -> Model -> Cell -> Html.Html
cellCol address model cell =
 Html.td [
           style (cellStyle model cell),
           Html.Events.onMouseDown address (SetClicking True),
           Html.Events.onMouseEnter address (CellUpdate SetActive cell)
         ] [
          p [] [text (cellDesc cell)]
          -- button [ onClick address (CellUpdate (SetNote "o") cell)] [ text "n" ]
         ]

cellStyle : Model -> Cell -> List (String, String)
cellStyle model cell = List.concat([cellWallStyleList model cell, cellBgStyleList model cell])

cellWallStyleList : Model -> Cell -> List (String, String)
cellWallStyleList model cell =
  let wallSides = List.filter (wallOnCellSide model cell) ["left", "right", "top", "bottom"]
  in
    List.map (\w -> ("border-" ++ w, "solid 1px black")) wallSides

wallForDir : Cell -> String -> Wall
wallForDir cell direction =
  case direction of
    "left" -> {startX = cell.x, endX = cell.x, startY = cell.y, endY = cell.y + 1 }
    "right" -> {startX = cell.x + 1, endX = cell.x + 1, startY = cell.y, endY = cell.y + 1 }
    "top" -> {startX = cell.x, endX = cell.x + 1, startY = cell.y, endY = cell.y}
    "bottom" -> {startX = cell.x, endX = cell.x + 1, startY = cell.y + 1, endY = cell.y + 1}
    _ -> {startX = -1, endX = -1, startY = -1, endY = -1 }

wallOnCellSide : Model -> Cell -> String -> Bool
wallOnCellSide model cell direction =
  List.member (wallForDir cell direction) model.board.walls


cellBgStyleList : Model -> Cell -> List (String, String)
cellBgStyleList model cell =
  let
      isActive = Set.member (cell.x, cell.y) model.activeCells
  in
  case isActive of
    True -> [("background-color", "aqua")]
    False -> []


cellDesc : Cell -> String
cellDesc cell = (cell.name ++ "-" ++ cell.note)

-- port playSong : Signal String
-- port playSong = Signal.map toString playerActions.signal

-- port songPos : Signal Float
