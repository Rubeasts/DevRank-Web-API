# frozen_string_literal: true

# Loads data from Facebook group to database
class LoadDeveloperFromGithub
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :validate_request_json, lambda { |request_body|
    begin
      name_representation = UsernameRequestRepresenter.new(UsernameRequest.new)
      Right(name_representation.from_json(request_body))
    rescue
      Left(Error.new(:bad_request, 'username could not be resolved'))
    end
  }

  register :validate_request_username, lambda { |body_params|
    if (dev_username = body_params['username']).nil?
      Left(Error.new(:cannot_process, 'username not supplied'))
    else
      Right(dev_username)
    end
  }

  register :check_if_developer_is_loaded, lambda { |dev_username|
    if Developer.find(username: dev_username)
      Left(Error.new(:cannot_process, "Developer (name: #{dev_username}) already exists"))
    else
      Right(dev_username)
    end
  }

  register :check_if_developer_exist, lambda { |dev_username|
    github_dev = Github::Developer.find(username: dev_username)
    unless github_dev
      Left(Error.new(:not_found, "Developer (name: #{dev_username}) could not be found"))
    else
      Right(github_dev)
    end
  }

  register :create_developer_and_repositories, lambda { |github_developer|
    developer = Developer.create(
      github_id: github_developer.id,
      username: github_developer.username)

    github_developer.repos.each do |gh_repo|
      write_developer_repository(developer, gh_repo)
    end
    Right(developer)
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :validate_request_json
      step :validate_request_username
      step :check_if_developer_is_loaded
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
