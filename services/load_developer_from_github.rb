# frozen_string_literal: true

# Loads data from Facebook group to database
class LoadDeveloperFromGithub
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :check_if_developer_exist, lambda { |input|
    github_dev = Github::Developer.find username: input[:username]
    if github_dev
      Right gh_dev: github_dev, channel_id: input[:channel_id]
    else
      Left Error.new  :not_found,
                      "Developer (username: #{input[:username]}) could not be found"
    end
  }

  register :create_developer_and_repositories, lambda { |input|
    begin
      github_developer = input[:gh_dev]
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

      channel_id = input[:channel_id]
      puts channel_id

      Right dev: developer, gh_dev: github_developer, channel_id: channel_id
    rescue
      Left(
        Error.new(
          :cannot_load,
          "Developer (username: #{input[:gh_dev].username}) could not be load"
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
        LoadRepository.call owner: owner, repo: repo, channel_id: channel_id
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
