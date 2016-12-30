require 'econfig'

class SaveQualityDataWorker
  extend Econfig::Shortcut
  Econfig.env = ENV['RACK_ENV'] || 'development'
  Econfig.root = File.expand_path('..', File.dirname(__FILE__))

  ENV['AWS_ACCESS_KEY_ID'] = config.AWS_ACCESS_KEY_ID
  ENV['AWS_SECRET_ACCESS_KEY'] = config.AWS_SECRET_ACCESS_KEY
  ENV['AWS_REGION'] = config.AWS_REGION
end
