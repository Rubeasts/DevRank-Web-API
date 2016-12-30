# frozen_string_literal: true

require_relative 'load_aws_env.rb'

Dir.glob("#{File.dirname(__FILE__)}/*_worker.rb").each do |file|
  require file
end
