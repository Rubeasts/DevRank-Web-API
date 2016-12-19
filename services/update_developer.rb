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
                      "Developer #{dev_username} could not be found"
    end
  }

  register :load_developer_from_github, lambda { |dev|
    github_dev = Github::Developer.find(username: dev.username)
    if github_dev
      Right developer: dev, github_dev: github_dev
    else
      Left Error.new  :not_found,
                      "Developer #{dev.username} could not be found on Github"
    end
  }

  register :update_developer, lambda { |input|
    begin
      dev = input[:developer]
      github_dev = input[:github_dev]
      dev.update github_id: github_dev.id, username: github_dev.username
      github_dev.repos.each do |gh_repo|
        owner, repo = gh_repo.full_name.split('/')
        UpdateRepository.call(owner: owner, repo: repo)
      end
      Right(dev)
    rescue
      Left Error.new :cannot_load, 'Developer could not be updated'
    end
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :check_if_developer_is_loaded
      step :load_developer_from_github
      step :update_developer
    end.call(params)
  end
end
