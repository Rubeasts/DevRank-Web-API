# frozen_string_literal: true
require 'sinatra'
require 'gitget'
require 'econfig'

require_relative 'base'

Dir.glob("#{File.dirname(__FILE__)}/*.rb").each do |file|
  require file
end
