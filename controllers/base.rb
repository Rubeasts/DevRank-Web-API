# frozen_string_literal: true

# configure based on environment
class DevRankAPI < Sinatra::Base
  extend Econfig::Shortcut

  Econfig.env = settings.environment.to_s
  Econfig.root = File.expand_path('..', settings.root)

  Github::API.config.update(username: config.GH_USERNAME,
                            token:    config.GH_TOKEN)

  API_VER = 'api/v0.1'.freeze

  get '/?' do
    "RankDev latest version endpoints are at: /#{API_VER}/"
  end
end