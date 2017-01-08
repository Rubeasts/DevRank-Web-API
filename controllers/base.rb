# frozen_string_literal: true

# configure based on environment
class DevRankAPI < Sinatra::Base
  extend Econfig::Shortcut

  Econfig.env = settings.environment.to_s
  Econfig.root = File.expand_path('..', settings.root)

  Github::API.config.update(username: config.GH_USERNAME,
                            token:    config.GH_TOKEN)

  API_VER = 'api/v0.1'

  get '/?' do
    "RankDev latest version endpoints are at: /#{API_VER}/"
  end

  def self.publish(channel_id, message)
    puts "publish #{channel_id}, #{message}"
    HTTP.headers('Content-Type' => 'application/json')
        .post("http://localhost:9292/faye",
              json: {
                channel: "/#{channel_id}",
                data: message
              })
  end
end
