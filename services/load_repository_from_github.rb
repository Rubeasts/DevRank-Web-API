# frozen_string_literal: true

# Loads data from Facebook group to database
class LoadRepositoryFromGithub
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :check_if_repository_exist, lambda { |repository|
    github_repo = Github::Repository.find(full_name: repository)
    if github_repo
      Right github_repo
    else
      Left Error.new  :not_found,
                      "Developer (repository: #{repository}) could not be found"
    end
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :check_if_repository_exist
    end.call(params)
  end

  private_class_method

  def self.write_developer_repository(developer, gh_repo)
    developer.add_repository(
      github_id: gh_repo.id,
      full_name: gh_repo.full_name,
      is_private: gh_repo.is_private,
      created_at: gh_repo.created_at,
      pushed_at: gh_repo.pushed_at,
      size: gh_repo.size,
      stargazers_count: gh_repo.stargazers_count,
      watchers_count: gh_repo.watchers_count,
      forks_count: gh_repo.forks_count,
      open_issues_count: gh_repo.open_issues_count
    )
  end
end
