# frozen_string_literal: true

# configure based on environment
class DevRankAPI < Sinatra::Base
  extend Econfig::Shortcut

  Shoryuken.configure_server do |config|
  	config.aws = {
  	  access_key_id:     config.AWS_ACCESS_KEY_ID,
  	  secret_access_key: config.AWS_SECRET_ACCESS_KEY,
  	  region:            config.AWS_REGION
  	}
  end

  Econfig.env = settings.environment.to_s
  Econfig.root = File.expand_path('..', settings.root)

  Github::API.config.update(username: config.GH_USERNAME,
                            token:    config.GH_TOKEN)

  API_VER = 'api/v0.1'

  get '/?' do
    "RankDev latest version endpoints are at: /#{API_VER}/"
  end
end
