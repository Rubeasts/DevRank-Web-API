Dir.glob('./{config,lib,models, controllers}/init.rb').each do |file|
  require file
end

require_relative 'app'
