# frozen_string_literal: true
require 'sinatra'
require 'gitget'
require 'econfig'

# DevRankAPI web service
class DevRankAPI < Sinatra::Base
  extend Econfig::Shortcut

  Econfig.env = settings.environment.to_s
  Econfig.root = settings.root
  Github::API.config = { username: ENV['GH_USERNAME'],
                       token: ENV['GH_TOKEN'] }

  API_VER = 'api/v0.1'

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
      halt 404, "Github Username (id: #{username}) not found"
    end
  end

  get "/#{API_VER}/dev/:username/repos/?" do
    developer_id = params[:username]
    begin
      dev = Github::Developer.find(username: developer_id)

      content_type 'application/json'
      { repos: dev.public_repos}.to_json
    rescue
      halt 404, "Cannot find (id: #{username}) repos"
    end
  end
end
