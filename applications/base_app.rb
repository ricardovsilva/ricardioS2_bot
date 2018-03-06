require 'sinatra/base'

class BaseApp < Sinatra::Base
  set :root, File.dirname(__FILE__)

  configure do
    enable :sessions
    enable :logging
    set :session_secret, ENV['TWITCH_SESSION_SECRET']
    set :client_id, ENV['TWITCH_CLIENT_ID']
    set :client_secret, ENV['TWITCH_CLIENT_SECRET']
    set :redirect_uri, ENV['TWITCH_REDIRECT_URI']
    set :scope, 'user_read'
  end
end