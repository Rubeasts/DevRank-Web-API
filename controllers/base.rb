# frozen_string_literal: true

# configure based on environment
class DevRankAPI < Sinatra::Base
  extend Econfig::Shortcut

  Econfig.env = settings.environment.to_s
  Econfig.root = File.expand_path('..', settings.root)

  Github::API.config.update(username: config.GH_USERNAME,
                            token:    config.GH_TOKEN)

  API_VER = 'api/v0.1'

  set :views, File.expand_path('../../views',__FILE__)
  set :public_dir, File.expand_path('../../public',__FILE__)

  after do
    content_type 'text/html'
  end

  get '/?' do
    "RankDev latest version endpoints are at: /#{API_VER}/"
  end

  def self.publish(channel_id, message)
    puts "publish #{channel_id}, #{message}, #{ENV['ROOT_URL']}"
    HTTP.headers('Content-Type' => 'application/json')
        .post("#{ENV['ROOT_URL']}/faye",
              json: {
                channel: "/#{channel_id}",
                data: message
              })
    puts 'published'
  end
end
