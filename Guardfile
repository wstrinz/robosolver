# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"
# notification :growl_notify

guard :shell do
  watch(%r{robosolver/robosolver_.+\.elm}) do
    if /cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM
      `elm-make robosolver\\robosolver_types.elm robosolver\\robosolver_client.elm robosolver\\robosolver_decoder.elm robosolver\\robosolver_encoder.elm robosolver\\robosolver_inits.elm robosolver\\robosolver_model.elm robosolver\\robosolver_persistence.elm  robosolver\\robosolver_queries.elm  robosolver\\robosolver_update_handler.elm robosolver\\robosolver_view.elm --output=elm.js`
    else
      `elm make robosolver/*.elm --output elm.js`
    end
  end
end
