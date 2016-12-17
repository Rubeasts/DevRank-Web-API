require_relative 'init.rb'

developer = Developer.find(username: 'rjollet')

def async_quality_update(developer)
  promised_data = developer.repositories.map do |repo|
    Concurrent::Promise.execute { UpdateRepositoryQualityData.call(repo) if repo.language.to_s.include? "Ruby" }
  end
  promised_data.map(&:value)
end


def quality_update(developer)
  developer.repositories.each do |repo|
    if repo.language.to_s.include? "Ruby"
      UpdateRepositoryQualityData.call(repo)
    end
  end
end

Benchmark.measure do
  5.times.map { quality_update(developer) }
end.real


Benchmark.measure do
  5.times.map { async_quality_update(developer) }
end.real
