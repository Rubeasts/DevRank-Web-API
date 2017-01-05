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
      input[:github_repo] = github_repo 
      Right input
    else
      Left Error.new  :not_found,
                      "Repository: #{input} could not be found"
    end
  }

<<<<<<< 44dc98132e4ef421944d4042b16654e9bff97200
  register :create_repository, lambda { |gh_repo|
    repository = Repository.new(
=======
  register :create_repository, lambda { |input|
    gh_repo = input[:github_repo]
    repository = Repository.create(
>>>>>>> passes the channel id
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
<<<<<<< 44dc98132e4ef421944d4042b16654e9bff97200

    Right repo: repository, gh_repo: gh_repo
  }

  register :add_stats_to_repo, lambda { |input|
    begin
      repo = input[:repo]
      gh_repo = input[:gh_repo]
      repo = add_stat_to_repo(repo, gh_repo.stats(stat_names: ['code_frequency','participation']))
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
=======
    input[:repository] = repository
    Right input
>>>>>>> passes the channel id
  }

  register :update_repo_code_quality, lambda { |input|
    repo = input[:repository]
    channel_id = input[:channel_id]
    if repo.language.to_s.include? 'Ruby'
      worker_params = {repo_id: repo.id, channel_id: channel_id}
      SaveQualityDataWorker.perform_async(
        QueueMessageRepresenter.new(QueueMessage.new(worker_params)).to_json
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
      code_frequency: stats[:code_frequency].to_s,
      participation: stats[:participation].to_s
    )
    repo
  end
end
