require 'econfig'
require 'shoryuken'

class SaveQualityDataWorker
  extend Econfig::Shortcut
  Econfig.env = ENV['RACK_ENV'] || 'development'
  Econfig.root = File.expand_path('..', File.dirname(__FILE__))

  ENV['AWS_ACCESS_KEY_ID'] = config.AWS_ACCESS_KEY_ID
  ENV['AWS_SECRET_ACCESS_KEY'] = config.AWS_SECRET_ACCESS_KEY
  ENV['AWS_REGION'] = config.AWS_REGION


  Shoryuken.configure_client do |shoryuken_config|
  	shoryuken_config.aws = {
  	  access_key_id:     SaveQualityDataWorker.config.AWS_ACCESS_KEY_ID,
  	  secret_access_key: SaveQualityDataWorker.config.AWS_SECRET_ACCESS_KEY,
  	  region:            SaveQualityDataWorker.config.AWS_REGION
  	}
  end

  include Shoryuken::Worker
  shoryuken_options queue: config.QUALITY_QUEUE, auto_delete: true

  def perform(_sqs_msg, input)
  	repo = input[:repo]
    quality_data = input[:quality_data]
    repo.flog_score = quality_data.get_flog_scores.to_s
    repo.flay_score = quality_data.get_flay_score.to_s
    repo.rubocop_errors = quality_data.get_rubocop_errors.to_s
    repo.save
    quality_data.wipe
  end
end
