# frozen_string_literal: true
# Loads data from Facebook group to database
class LoadRepositoryFromGithub
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :check_if_repository_exist, lambda { |input|
    owner = input[:owner]
    repo = input[:repo]
    github_repo = Github::Repository.find(owner: owner, repo: repo)
    if github_repo
      Right github_repo
    else
      Left Error.new  :not_found,
                      "Repository: #{input} could not be found"
    end
  }

  register :create_repository, lambda { |gh_repo|
    repository = Repository.create(
      github_id: gh_repo.id, full_name: gh_repo.full_name,
      is_private: gh_repo.is_private, created_at: gh_repo.created_at,
      pushed_at: gh_repo.pushed_at, size: gh_repo.size,
      stargazers_count: gh_repo.stargazers_count,
      watchers_count: gh_repo.watchers_count,
      forks_count: gh_repo.forks_count,
      open_issues_count: gh_repo.open_issues_count
    )

    Right repository
  }

  register :update_repo_code_quality, lambda { |repo|
    if repo.language.to_s.include? "Ruby"
      UpdateRepositoryQualityData.call(repo)
    end
    Right repo
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :check_if_repository_exist
      step :create_repository
      step :update_repo_code_quality
    end.call(params)
  end
end
