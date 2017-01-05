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
    repository = Repository.new(
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

    owner, _ = gh_repo.full_name.split('/')
    if(dev = Developer.find(username: owner))
      repository.developer_id = dev.id
    end

    Right repo: repository, gh_repo: gh_repo
  }

  register :add_stats_to_repo, lambda { |input|
    begin
      repo = input[:repo]
      gh_repo = input[:gh_repo]
      repo = add_stat_to_repo(repo, gh_repo.stats)
      Right repo
    rescue
      Left Error.new  :cannot_load,
                      "Cannot load stat to #{repo.full_name}"
    end
  }

  register :save_repo_to_db, lambda { |repo|
    begin
      repo.save
      Right repo
    rescue
      Left Error.new  :cannot_load,
                      "Cannot save to #{repo.full_name}"
    end
  }

  register :update_repo_code_quality, lambda { |repo|
    if repo.language.to_s.include? 'Ruby'
      SaveQualityDataWorker.perform_async(
        QueueMessageRepresenter.new(QueueMessage.new(repo.id)).to_json
      )
    end
    Right repo
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :check_if_repository_exist
      step :create_repository
      step :add_stats_to_repo
      step :save_repo_to_db
      step :update_repo_code_quality
    end.call(params)
  end

  def self.add_stat_to_repo(repo, stats)
    repo.stat = Stat.create(
      contributors: stats[:contributors],
      commit_activity: stats[:commit_activity],
      code_frequency: stats[:code_frequency],
      participation: stats[:participation],
      punch_card: stats[:punch_card]
    )
    repo
  end
end
