# frozen_string_literal: true

# Loads data from Facebook group to database
class UpdateDeveloper
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :check_if_developer_is_loaded, lambda { |dev_username|
    if (dev = Developer.find(username: dev_username))
      Right dev
    else
      Left Error.new  :not_found,
                      "Developer (username: #{dev_username}) could not be found"
    end
  }

  register :load_developer_from_github, lambda { |dev|
    github_dev = Github::Developer.find(username: dev.username)
    if github_dev
      Right developer: dev, github_dev: github_dev
    else
      Left Error.new  :not_found,
                      "Developer (username: #{dev.username}) could not be found"
    end
  }

  register :update_developer, lambda { |input|
    begin
      dev = input[:developer]
      github_dev = input[:github_dev]
      dev.update github_id: github_dev.id, username: github_dev.username
      dev.repositories.map(&:delete)
      github_dev.repos.each do |gh_repo|
        write_developer_repository dev, gh_repo
      end
      Right(dev)
    rescue
      Left Error.new :cannot_load, 'Developer could not be updated'
    end
  }

  register :update_repo_code_quality, lambda { |developer|
    developer.repositories.each do |repo|
      if repo.language.to_s.include? 'Ruby'
        UpdateRepositoryQualityData.call(repo)
      end
    end
    Right developer
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :check_if_developer_is_loaded
      step :load_developer_from_github
      step :update_developer
      step :update_repo_code_quality
    end.call(params)
  end

  private_class_method

  def self.write_developer_repository(developer, gh_repo)
    developer.add_repository(
      github_id: gh_repo.id, full_name: gh_repo.full_name,
      is_private: gh_repo.is_private, created_at: gh_repo.created_at,
      pushed_at: gh_repo.pushed_at, size: gh_repo.size,
      stargazers_count: gh_repo.stargazers_count,
      watchers_count: gh_repo.watchers_count,
      forks_count: gh_repo.forks_count,
      open_issues_count: gh_repo.open_issues_count,
      language: gh_repo.language,
      git_url: gh_repo.git_url
    )
  end
end
