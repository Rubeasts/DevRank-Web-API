require 'sinatra'
require 'econfig'
require 'gitget'
require 'sequel'
require_relative 'base'

Dir.glob("#{File.dirname(__FILE__)}/*.rb").each do |file|
  require file
end
