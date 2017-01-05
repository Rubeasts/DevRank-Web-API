require 'shoryuken'
require_relative 'load_aws_env'

class SaveQualityDataWorker
  include Shoryuken::Worker

  require_relative '../values/init.rb'
  require_relative '../config/init.rb'
  require_relative '../models/init.rb'
  require_relative '../representers/init.rb'
  require_relative '../services/init.rb'

  shoryuken_options queue: config.QUALITY_QUEUE, auto_delete: true

  def perform(_sqs_msg, queue_message)
    puts queue_message
  	AddRubyRepositoryQualityData.call(queue_message)
  end
end
