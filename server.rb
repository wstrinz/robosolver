require 'tilt/erb'
require 'sinatra'
require 'sinatra/reloader' if development?

get "/test" do
  "yep"
end

get "/" do
  erb :index
end

get "/elm.js" do
  send_file "elm.js"
end
