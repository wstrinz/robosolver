module RobosolverView where
import Set
import RobosolverQueries exposing (wallOnCellSide, findCell)
import RobosolverTypes exposing (Cell, Wall, Model, Action(..), CellOperation(..))
import RobosolverModel exposing (spaceTypes, entityTypes)
import RobosolverEncoder exposing (modelToJson)
import Html exposing (Html, div, text, button, p, br, option)
import Html.Attributes exposing (src, attribute, style)
import Html.Events exposing (onClick)
import Json.Decode exposing (..)

view : Signal.Address Action -> Model -> Html.Html
view address model = div [Html.Events.onMouseUp address (SetClicking False Nothing)] [
    Html.table [style (List.append tableStyle noSelectStyle)] (cellsDiv address model),
    button [ onClick address (ResetActiveCells)] [ text "Clear Selection" ],
    cellEditor address model,
    modelDisp model
  ]

tableStyle : List (String, String)
tableStyle = [("border", "solid 1px black"),("width", "80%"),("height","80%"),("font-size","2.5em")]

modelDisp : Model -> Html.Html
modelDisp model = div [] [
  p [] [text (modelToJson model)]
  ]
-- modelDisp model = div [] [
--   p [] [text <| toString <| model.board.rows]
--   ]

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
          div [] (realWallButtons address model cell)
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
          p [] [text (cellDesc model cell)]
         ]

cellStyle : Model -> Cell -> List (String, String)
cellStyle model cell = List.concat([cellWallStyleList model cell, cellBgStyleList model cell, cellRobitStyleList model cell])

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
    True ->
      case cell.color of
        "" -> [("outline", "3px solid aqua")]
        col -> [("outline", "3px solid aqua"), ("background-color", col)]

    False ->
      case cell.color of
        "" -> []
        col -> [("background-color", col)]

cellRobitStyleList : Model -> Cell -> List (String, String)
cellRobitStyleList model cell =
  let
    robotInCell = List.head <| List.filter (\r -> (fst r.coords == cell.x) && (snd r.coords == cell.y)) model.board.robits
  in
    case robotInCell of
      Just robit ->
        [("font-weight", "bold"), ("color", robit.color)]
      _ -> []

cellDesc : Model -> Cell -> String
cellDesc model cell =
  let
    robotInCell = List.head <| List.filter (\r -> (fst r.coords == cell.x) && (snd r.coords == cell.y)) model.board.robits
  in
    case robotInCell of
      Just robit ->
        "☻"
      _ ->
        case cell.symbol of
          "star" -> "☆"
          "gear" -> "g"
          "moon" -> "☾"
          "planet" -> "ⴲ"
          _ -> (cell.name ++ "-" ++ cell.note)

-- buttons
realWallButtons : Signal.Address Action -> Model -> Cell -> List Html.Html
realWallButtons address model cell = [
            p [] [text "Toggle Walls"],
            button [ onClick address (CellUpdate (ClearWalls) cell)] [ text "Clear Walls" ],
            Html.br [] [],
            button [ onClick address (CellUpdate (ToggleWall "left") cell)] [ text "Left" ],
            button [ onClick address (CellUpdate (ToggleWall "right") cell)] [ text "Right" ],
            button [ onClick address (CellUpdate (ToggleWall "top") cell)] [ text "Top" ],
            button [ onClick address (CellUpdate (ToggleWall "bottom") cell)] [ text "Bottom" ],
            Html.br [] [],
            div [] <| spaceSelection address model cell
          ]

spaceSelection : Signal.Address Action -> Model -> Cell -> List Html.Html
spaceSelection address model cell =
  case Set.size model.activeCells of
    1 -> [(spaceTypeSelect address model cell),
          (spaceEntityeSelect address model cell)]
    _ -> []

idxToSignal :  Signal.Address Action -> Cell -> Int -> Signal.Message
idxToSignal address cell idx =
  let
    messageFor color symbol = Signal.message address (CellUpdate (SelectType (color, symbol)) cell)
  in
  case idx of
     1  -> messageFor "red" "star"
     2  -> messageFor "red" "moon"
     3  -> messageFor "red" "gear"
     4  -> messageFor "red" "planet"
     5  -> messageFor "yellow" "star"
     6  -> messageFor "yellow" "moon"
     7  -> messageFor "yellow" "gear"
     8  -> messageFor "yellow" "planet"
     9  -> messageFor "blue" "star"
     10 -> messageFor "blue" "moon"
     11 -> messageFor "blue" "planet"
     12 -> messageFor "blue" "gear"
     13 -> messageFor "green" "star"
     14 -> messageFor "green" "moon"
     15 -> messageFor "green" "planet"
     16 -> messageFor "green" "gear"
     17 -> messageFor "purple" "wild"
     _  -> messageFor "" ""

idxForSpaceType : (String, String) -> Int
idxForSpaceType spaceType =
  case spaceType of
      ("red", "star")     -> 1
      ("red", "moon")     -> 2
      ("red", "gear")     -> 3
      ("red", "planet")   -> 4
      ("yellow", "star")  -> 5
      ("yellow", "moon")  -> 6
      ("yellow", "gear")  -> 7
      ("yellow", "planet")-> 8
      ("blue", "star")    -> 9
      ("blue", "moon")    -> 10
      ("blue", "planet")  -> 11
      ("blue", "gear")    -> 12
      ("green", "star")   -> 13
      ("green", "moon")   -> 14
      ("green", "planet") -> 15
      ("green", "gear")   -> 16
      ("purple", "wild")  -> 17
      ("", "")            -> 0
      _                   -> 0

robitIdxToSignal :  Signal.Address Action -> Cell -> Int -> Signal.Message
robitIdxToSignal address cell idx =
  let
    messageFor color = Signal.message address (CellUpdate (SetEntity color) cell)
  in
  case idx of
     1  -> messageFor "red"
     2  -> messageFor "green"
     3  -> messageFor "yellow"
     4  -> messageFor "blue"
     _  -> messageFor ""

onSelect : Signal.Address Action -> Model -> Cell -> Html.Attribute
onSelect address model cell =
  Html.Events.on "change"
  (Json.Decode.at ["target", "selectedIndex"] Json.Decode.int)
  (idxToSignal address cell)

onSelectRobit : Signal.Address Action -> Model -> Cell -> Html.Attribute
onSelectRobit address model cell =
  Html.Events.on "change"
  (Json.Decode.at ["target", "selectedIndex"] Json.Decode.int)
  (robitIdxToSignal address cell)

spaceTypeSelect : Signal.Address Action -> Model -> Cell -> Html.Html
spaceTypeSelect address model cell = Html.select [onSelect address model cell] <| spaceTypeOptions cell

spaceTypeOptions : Cell -> List Html.Html
spaceTypeOptions cell =
  let
    optionProps spaceType =
      if (cell.color, cell.symbol) == spaceType then
        [Html.Attributes.selected True]
      else
        []

    spaceOption spaceType =
      option (optionProps spaceType) [text ((fst spaceType) ++ " " ++ (snd spaceType))]
  in
    List.map spaceOption spaceTypes

spaceEntityeSelect : Signal.Address Action -> Model -> Cell -> Html.Html
spaceEntityeSelect address model cell = Html.select [onSelectRobit address model cell] <| spaceEntityOptions model cell

spaceEntityOptions : Model -> Cell -> List Html.Html
spaceEntityOptions model cell =
  let
      robotInCell robitType = List.head <| List.filter (\r -> (fst robitType == r.color) && (fst r.coords) == cell.x && (snd r.coords) == cell.y) model.board.robits
      optionProps robitType =
        case robotInCell robitType of
          Just robit -> [Html.Attributes.selected True]
          _ -> []
  in
    List.map
      (\t -> option (optionProps t) [text ((fst t) ++ " " ++ (snd t))])
      entityTypes

disabledWallButtons : List Html.Html
disabledWallButtons =
  [
    p [] [text "Toggle Walls"],
    button [] [ text "Left" ],
    button [] [ text "Right" ],
    button [] [ text "Top" ],
    button [] [ text "Bottom" ]
    ]

-- Select Box

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
