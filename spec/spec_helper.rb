# frozen_string_literal: true
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'vcr'
require 'webmock'

require_relative '../init.rb'

include Rack::Test::Methods

def app
  DevRankAPI
end

FIXTURES_FOLDER = 'spec/fixtures'
CASSETTES_FOLDER = "#{FIXTURES_FOLDER}/cassettes"
DEV_CASSETTE = 'dev'
REPO_CASSETTE = 'repo'

VCR.configure do |c|
  c.cassette_library_dir = CASSETTES_FOLDER
  c.ignore_hosts 'sqs.us-east-1.amazonaws.com'
  c.hook_into :webmock

  c.filter_sensitive_data('<AUTH>') { app.config.GH_AUTH }
end

HAPPY_USERNAME = 'rjollet'
SAD_USERNAME = '12547sdf'
HAPPY_REPO = 'SOA_flip_flap'
SAD_REPO = 'blabla'
HAPPY_OWNER = 'rjollet'
HAPPY_FULL_NAME = [HAPPY_USERNAME, HAPPY_REPO].join('/')
CHANNEL_ID = 'test'.hash
