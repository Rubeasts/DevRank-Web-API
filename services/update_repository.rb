# frozen_string_literal: true

# Loads data from Facebook group to database
class UpdateRepository
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :check_if_repository_is_loaded, lambda { |input|
    full_name = [input[:owner], input[:repo]].join('/')

    if (repo = Repository.find(full_name: full_name))
      Right(repo)
    else
      Left Error.new  :not_found,
                      "Repository: #{input} could not be found"
    end
  }

  register :load_repository_from_github, lambda { |repo|
    repo_split = repo.full_name.split('/')
    github_repo = Github::Repository.find(owner: repo_split[0], repo: repo_split[1])
    if github_repo
      Right(repo: repo, github_repo: github_repo)
    else
      Left Error.new  :cannot_load,
                      "Repository #{repo} could not be loaded from Github"
    end
  }

  register :update_repository, lambda { |input|
    begin
      repo = input[:repo]
      github_repo = input[:github_repo]
      repo.update(
        github_id: github_repo.id, full_name: github_repo.full_name,
        is_private: github_repo.is_private, created_at: github_repo.created_at,
        pushed_at: github_repo.pushed_at, size: github_repo.size,
        stargazers_count: github_repo.stargazers_count,
        watchers_count: github_repo.watchers_count,
        forks_count: github_repo.forks_count,
        open_issues_count: github_repo.open_issues_count
      )
      Right(repo)
    rescue
      Left Error.new :cannot_load, 'Repository could not be updated'
    end
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :check_if_repository_is_loaded
      step :load_repository_from_github
      step :update_repository
    end.call(params)
  end
end
