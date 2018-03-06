require 'dotenv'
require 'sinatra'
require 'json'
require 'oauth2'
require 'securerandom'

Dotenv.load

configure do
  enable :sessions
  enable :logging
  set :session_secret, ENV['TWITCH_SESSION_SECRET']
  set :client_id, ENV['TWITCH_CLIENT_ID']
  set :client_secret, ENV['TWITCH_CLIENT_SECRET']
  set :redirect_uri, ENV['TWITCH_REDIRECT_URI']
  set :scope, 'user_read'
end

def client
  OAuth2::Client.new(
    settings.client_id,
    settings.client_secret, 
    site: 'https://api.twitch.tv',
    authorize_url: '/kraken/oauth2/authorize',
    token_url: '/kraken/oauth2/token')
end

get '/auth/twitch' do
   session[:state] = SecureRandom.base64
   redirect client.auth_code.authorize_url(
     redirect_uri: settings.redirect_uri,
     state: session[:state],
     scope: settings.scope)
end

get '/auth/twitch/callback' do
  if session[:state] === params[:state]
    access_token = client.auth_code.get_token(
      params[:code],
      redirect_uri: settings.redirect_uri)
    session[:access_token] = access_token.token
  else
    session.delete(:state)
  end
  redirect '/'
end

get '/' do
  if session[:access_token]
    access_token = OAuth2::AccessToken.new(
      client,
      session[:access_token],
      header_format: 'OAuth %s')

    puts access_token
    puts access_token[:token]
    response = access_token.get(
      "/kraken/user",
      headers: {
        'Client-ID': settings.client_id, 
        'Accept': 'application/vnd.twitchtv.v5+json'
    })
    profile = JSON.parse(response.body)
    puts profile
    puts profile["display_name"]
    erb :index_authenticated, locals: {'profile': profile, 'access_token': access_token}
  else
    erb :index_unauthenticated
  end
end