# frozen_string_literal: true
require 'sinatra'
require 'sequel'

configure :development do
  ENV['DATABASE_URL'] = 'sqlite://db/dev.db'
  ENV['ROOT_URL'] = 'http://localhost:9000'
end

configure :test do
  ENV['DATABASE_URL'] = 'sqlite://db/test.db'
  ENV['ROOT_URL'] = 'http://localhost:9292'
end

configure :development, :production do
  require 'hirb'
  Hirb.enable
end

configure do
  DB = Sequel.connect(ENV['DATABASE_URL'])
end
