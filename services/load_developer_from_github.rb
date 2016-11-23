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
      username: github_developer.username)

    github_developer.repos.each do |gh_repo|
      write_developer_repository developer, gh_repo
    end
    Right developer
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :check_if_developer_exist
      step :create_developer_and_repositories
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
