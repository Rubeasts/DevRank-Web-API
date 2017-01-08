# frozen_string_literal: true

# Loads data from Facebook group to database
class LoadDeveloperFromGithub
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :check_if_developer_exist, lambda { |dev_username|
    github_dev = Github::Developer.find(username: dev_username)
    if github_dev
      Right github_dev
    else
      Left Error.new  :not_found,
                      "Developer (username: #{dev_username}) could not be found"
    end
  }

  register :create_developer_and_repositories, lambda { |github_developer|
    begin
      developer = Developer.create(
        github_id: github_developer.id,
        username: github_developer.username,
        avatar_url: github_developer.avatar_url,
        name: github_developer.name,
        location: github_developer.location,
        email: github_developer.email,
        followers: github_developer.followers.count,
        following: github_developer.following.count,
        stars: github_developer.starred.count
      )
      Right(dev: developer, gh_dev: github_developer)
    rescue
      Left(
        Error.new(
          :cannot_load,
          "Developer (username: #{github_developer.username}) could not be load"
        )
      )
    end
  }

  register :load_developer_repositories, lambda { |input|
    begin
      developer = input[:dev]
      github_developer = input[:gh_dev]
      repo_monads = github_developer.repos.map do |gh_repo|
        owner, repo = gh_repo.full_name.split('/')
        LoadRepository.call(owner: owner, repo: repo)
      end
      if repo_monads.map(&:success?)
        Right developer
      else
        repo_monads.map(&:value)
      end
    rescue
      Left(
        Error.new(
          :cannot_load,
          "Developer #{developer.username} repositories could not be load"
        )
      )
    end
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :check_if_developer_exist
      step :create_developer_and_repositories
      step :load_developer_repositories
    end.call(params)
  end
end
