# frozen_string_literal: true
require 'sinatra'
require 'gitget'
require 'econfig'
require 'json'

# DevRankAPI web service
class DevRankAPI < Sinatra::Base
  extend Econfig::Shortcut

  Econfig.env = settings.environment.to_s
  Econfig.root = settings.root
  Github::API.config = { username: ENV['GH_USERNAME'],
                         token:    ENV['GH_TOKEN'] }

  API_VER = 'api/v0.1'.freeze

  get '/?' do
    "RankDev latest version endpoints are at: /#{API_VER}/"
  end

  get "/#{API_VER}/dev/:username/?" do
    developer_id = params[:username]
    begin
      dev = Github::Developer.find(username: developer_id)

      content_type 'application/json'
      { userid: dev.id, username: dev.name }.to_json
    rescue
      halt 404, "Github Username: #{developer_id} not found"
    end
  end

  get "/#{API_VER}/dev/:username/repos/?" do
    developer_id = params[:username]
    begin
      dev = Github::Developer.find(username: developer_id)
      if unless dev.nil?
        content_type 'application/json'
        { repos: dev.repos }.to_json
      else
        halt 404, "Cannot find Username: #{developer_id} repos"
      end
    rescue
      halt 404, "Cannot find Username: #{developer_id} repos"
    end
  end
end
