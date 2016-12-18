require_relative 'init.rb'
require 'benchmark'

DEVS = ['rjollet', 'NicholasDanks', 'samilaaroussi', 'fabiodaio', 'isaacmtz90']
developers = DEVS.map { |username| LoadDeveloper.call(username).value }

def async_quality_update(developer)
  promised_data = developer.repositories.map do |repo|
    Concurrent::Promise.execute { UpdateRepositoryQualityData.call(repo) if repo.language.to_s.include? "Ruby" }
  end
  promised_data.map(&:value)
end

def quality_update(developer)
  developer.repositories.each do |repo|
    if repo.language.to_s.include? 'Ruby'
      UpdateRepositoryQualityData.call(repo)
    end
  end
end

norm = Benchmark.measure do
  developers.each { |developer| quality_update(developer) }
end.real

conc = Benchmark.measure do
  developers.each { |developer| async_quality_update(developer) }
end.real

puts "Normal = #{norm}"
puts "Conc = #{conc}"
