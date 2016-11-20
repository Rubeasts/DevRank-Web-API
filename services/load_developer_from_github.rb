# frozen_string_literal: true

# Loads data from Facebook group to database
class LoadDeveloperFromGithub
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :validate_request_json, lambda { |request_body|
    begin
      name_representation = NameRequestRepresenter.new(NameRequest.new)
      Right(name_representation.from_json(request_body))
    rescue
      Left(Error.new(:bad_request, 'URL could not be resolved'))
    end
  }

  register :validate_request_name, lambda { |body_params|
    if (developer_name = body_params['name']).nil?
      Left(:cannot_process, 'URL not supplied')
    else
      Right(developer_name)
    end
  }

  register :check_if_developer_is_loaded, lambda { |developer_name|
    if Developer.find(name: developer_name)
      Left(Error.new(:cannot_process, "Developer (name: #{developer_name}) already exists"))
    else
      Right(developer_name)
    end
  }

  register :check_if_developer_exist, lambda { |developer_name|
    github_dev = Github::Developer.find(username: developer_name)
    unless github_dev
      Left(Error.new(:not_found, "Developer (name: #{developer_name}) could not be found"))
    else
      Right(github_dev)
    end
  }

  register :create_developer_and_repositories, lambda { |github_developer|
    developer = Developer.create(
      github_id: github_developer.id,
      name: github_developer.name)

    github_developer.repos.each do |gh_repo|
      write_developer_repository(developer, gh_repo)
    end
    Right(developer)
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :validate_request_json
      step :validate_request_name
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
