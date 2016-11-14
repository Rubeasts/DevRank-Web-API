Dir.glob('./{config,lib,models}/init.rb').each do |file|
  require file
end

require_relative 'app'
