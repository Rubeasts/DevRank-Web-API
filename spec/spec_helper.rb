# frozen_string_literal: true
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'vcr'
require 'webmock'

require_relative '../app'

include Rack::Test::Methods

def app
  DevRankAPI
end

FIXTURES_FOLDER = 'spec/fixtures'.freeze
CASSETTES_FOLDER = "#{FIXTURES_FOLDER}/cassettes".freeze
DEV_CASSETTE = 'dev'.freeze

VCR.configure do |c|
  c.cassette_library_dir = CASSETTES_FOLDER
  c.hook_into :webmock

  c.filter_sensitive_data('<AUTH>') { ENV['GH_AUTH'] }
end
