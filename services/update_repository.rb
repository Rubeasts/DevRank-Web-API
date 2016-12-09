# frozen_string_literal: true

# Loads data from Facebook group to database
class UpdateRepository
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :check_if_repository_is_loaded, lambda { |repository|
    if (repo = Repository.find(repository: repository))
      Right repo
    else
      Left Error.new  :not_found,
                      "Repository (repository: #{repository}) could not be found"
    end
  }

  register :load_repository_from_github, lambda { |repo|
    github_repo = Github::Repository.find(repository: repo)
    if github_repo
      Right repository: repo, github_repo: github_repo
    else
      Left Error.new  :not_found,
                      "Repository (repository: #{repo}) could not be found"
    end
  }

  register :update_repository, lambda { |input|
    begin
      dev = input[:developer]
      github_dev = input[:github_dev]
      dev.update github_id: github_dev.id, username: github_dev.username
      dev.repositories.map(&:delete)
      github_dev.repos.each do |gh_repo|
        write_developer_repository(dev, gh_repo)
      end
      Right(dev)
    rescue
      Left Error.new :cannot_load, 'Developer could not be updated'
    end
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :check_if_repository_is_loaded
      step :load_repository_from_github
      step :update_repository
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
