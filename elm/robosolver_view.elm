module RobosolverView where
import Set
import RobosolverQueries exposing (wallOnCellSide, findCell)
import RobosolverTypes exposing (Cell, Wall, Model, Action(..), CellOperation(..))
import Html exposing (Html, div, text, button, p, br)
import Html.Attributes exposing (src, attribute, style)
import Html.Events exposing (onClick)

view : Signal.Address Action -> Model -> Html.Html
view address model = div [Html.Events.onMouseUp address (SetClicking False Nothing), style noSelectStyle] [
    Html.table [style [("border", "solid 1px black")]] (cellsDiv address model),
    button [ onClick address (ResetActiveCells)] [ text "Clear Selection" ],
    cellEditor address model,
    modelDisp model
  ]

modelDisp : Model -> Html.Html
modelDisp model = div [] [
  p [] [text <| toString <| model.board.rows]
  ]

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
          p [] <| List.map
                   (\thecell -> text <| "editing " ++  (toString thecell))
                   <| Set.toList model.activeCells,
          div [] (realWallButtons address cell)
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
           Html.Events.onMouseDown address (SetClicking True (Just cell)),
           Html.Events.onMouseEnter address (CellUpdate SetActive cell)
         ] [
          p [] [text (cellDesc cell)]
         ]

cellStyle : Model -> Cell -> List (String, String)
cellStyle model cell = List.concat([cellWallStyleList model cell, cellBgStyleList model cell])

cellWallStyleList : Model -> Cell -> List (String, String)
cellWallStyleList model cell =
  let wallSides = List.filter (wallOnCellSide model cell) ["left", "right", "top", "bottom"]
  in
    List.map (\w -> ("border-" ++ w, "solid 2px black")) wallSides

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

-- buttons
realWallButtons : Signal.Address Action -> Cell -> List Html.Html
realWallButtons address cell = [
            p [] [text "Toggle Walls"],
            button [ onClick address (CellUpdate (ClearWalls) cell)] [ text "Clear Walls" ],
            Html.br [] [],
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

-- Styles
noSelectStyle : List (String, String)
noSelectStyle = [
  ("-webkit-touch-callout", "none"),
  ("-webkit-user-select", "none"),
  ("-khtml-user-select", "none"),
  ("-moz-user-select", "none"),
  ("-ms-user-select", "none"),
  ("user-select", "none")
  ]
