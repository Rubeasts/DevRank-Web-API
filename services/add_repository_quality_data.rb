# frozen_string_literal: true

# Loads data from Facebook group to database
class UpdateRepository
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :check_if_repository_is_loaded, lambda { |repo_github_id|
    if (rep = Repository.find(github_id: repo_github_id))
      Right rep
    else
      Left Error.new  :not_found,
                      "Repository (github_id: #{repo_github_id}) could not be found"
    end
  }

  register :load_repository_quality_data, lambda { |repo|
    devname = repo.full_name.split('/').first
    reponame = repo.full_name.split('/').last
    quality_data = GetCloneData.new(devname, reponame)
    if quality_data
      repo.flog_score = quality_data.get_flog_scores
      repo.flay_score = quality_data.get_flay_score
      repo.rubocop_errors = quality_data.get_rubocop_errors

      Right repo
    else
      Left Error.new  :not_found,
                      "Quality Data could not be found"
    end
  }

  
  def self.call(params)
    Dry.Transaction(container: self) do
      step :check_if_repository_is_loaded
      step :load_repository_quality_data
    end.call(params)
  end
end
