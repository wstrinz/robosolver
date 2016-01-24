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
  watch(%r{elm/robosolver_.+\.elm}) do
    if /cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM
      `elm-make elm\\robosolver_client.elm elm\\robosolver_decoder.elm elm\\robosolver_encoder.elm elm\\robosolver_inits.elm elm\\robosolver_model.elm elm\\robosolver_persistence.elm elm\\robosolver_queries.elm elm\\robosolver_types.elm elm\\robosolver_update_handler.elm elm\\robosolver_view.elm --output=elm.js`
    else
      `elm make elm/*.elm --output elm.js`
    end
  end
end
