# spec/spec_helper.rb
require 'rack/test'
require 'rspec'
require 'dotenv'

Dotenv.load

require_relative '../app.rb'

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure { |c| c.include RSpecMixin }
