# frozen_string_literal: true

# Loads data from Facebook group to database
class LoadRepository
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :check_if_repository_is_loaded, lambda { |repository|
    if (github_repo = Repository.find(full_name: repository))
      Right github_repo
    else
      LoadRepositoryFromGithub.call repository
    end
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :check_if_repository_is_loaded
    end.call(params)
  end
end
