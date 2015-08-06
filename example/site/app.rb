require 'sinatra'
require 'sinatra/content_for'
require 'dotenv'
Dotenv.load

MIXPANEL_TOKEN=ENV['MIXPANEL_TOKEN']

get '/' do

  erb :index
end

get '/page1' do
  erb :page1
end

get '/page2' do
  erb :page2
end

get '/thankyou' do
  erb :thankyou
end

