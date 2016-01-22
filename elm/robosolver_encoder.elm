module RobosolverEncoder where
import Json.Encode as ENC exposing (string, int, object)
import RobosolverTypes exposing (..)

a = 1

-- jModel : Model -> ENC.Value
-- jModel model = object [
--     ("counta", int model.counta),
--     ("countb", int model.countb),
--     ("page", string (toString model.page)),
--     ("state", string (toString model.state))
--   ]

-- modelToJson : Model -> String
-- modelToJson model = ENC.encode 0 (jModel model)

-- modelFromJson : String -> Model
-- modelFromJson json =
--   let decodeResult = Decode.decodeString modelDecoder json
--   in
--     case decodeResult of
--       Result.Ok mod -> modelFromStringy mod
--       Result.Err errStr -> initialModel

-- modelDecoder : Decoder StringyModel
-- modelDecoder =
--   Decode.object4 StringyModel
--     ("counta" := Decode.int)
--     ("countb" := Decode.int)
--     ("page" := Decode.string)
--     ("state" := Decode.string)


