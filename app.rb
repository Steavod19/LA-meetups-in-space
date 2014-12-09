require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

get '/' do
  @meetups = Meetup.all
  erb :index
end


get '/create' do
  erb :create
end

post '/create' do
  require 'pry'
  meetup = Meetup.create(
  title: params[:title],
  description: params[:description],
  location: params[:location],
  start_date: params[:start_date],
  start_time: params[:start_time],
  created_by: current_user.id )
  redirect "/meetups/#{meetup.id}"
end

get '/meetups/:id' do
  @meetup = Meetup.find_by id: params[:id]
  @user = User.find_by id: @meetup.created_by
  erb :show_meetup
end

post '/add_attendee' do
  Attendee.create(
  user_id: current_user.id,
  meetup_id: params[:meetup])
  redirect "/meetups/#{params[:meetup]}"
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end
