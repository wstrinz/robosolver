module RobosolverPersistence where
-- import LocalStorage
-- import RobosolverInits exposing (initialModel)
-- import RobosolverDecoder exposing (modelFromJson)
-- import RobosolverTypes exposing (..)
-- import RobosolverEncoder exposing (modelToJson)
-- import Task exposing (Task, andThen)

-- Disabled for now, just using ports

-- saveModel : Model -> Task LocalStorage.Error String
-- saveModel model = LocalStorage.set "model-key" (modelToJson model)
--
-- loadModel : Signal.Address Action -> Task LocalStorage.Error ()
-- loadModel address =
--   let handle str =
--     case str of
--       Just s -> Signal.send address (SetModel (modelFromJson s))
--       Nothing -> Signal.send address (SetModel (initialModel))
--     in
--      (LocalStorage.get "model-key") `andThen` handle
--
--

a = 1
