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

    github_developer.repos.each do |gh_repo|
      owner, repo = gh_repo.full_name.split('/')
      LoadRepository.call(owner: owner, repo: repo)
    end
    Right developer
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :check_if_developer_exist
      step :create_developer_and_repositories
    end.call(params)
  end
end
