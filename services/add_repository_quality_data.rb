# frozen_string_literal: true

# Loads data from Facebook group to database
class UpdateRepositoryQualityData
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :load_repository_quality_data, lambda { |repo|
    quality_data = GetCloneData::ClonedRepo.clone(git_url: repo.git_url)
    if quality_data
      Right(repo: repo, quality_data: quality_data)
    else
      Left Error.new  :not_found, "Quality Data could not be found"
    end
  }

  register :save_repository_quality_data, lambda { |input|
    begin
      repo = input['repo']
      quality_data = input['quality_data']
      repo.flog_score = quality_data.flog.to_s
      repo.flay_score = quality_data.flay.to_s
      repo.rubocop_errors = quality_data.rubocop.to_s
      repo.save
      Right repo
    rescue
      Left Error.new  :cannot_load, "Quality Data cannot be load"
    end
  }


  def self.call(params)
    Dry.Transaction(container: self) do
      step :load_repository_quality_data
      step :save_repository_quality_data
    end.call(params)
  end
end
