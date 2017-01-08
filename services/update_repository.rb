# frozen_string_literal: true

# Loads data from Facebook group to database
class UpdateRepository
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :check_if_repository_is_loaded, lambda { |input|
    full_name = [input[:owner], input[:repo]].join('/')
    if (repo = Repository.find(full_name: full_name))
      Right(repo)
    else
      Left Error.new  :not_found,
                      "Repository: #{input} could not be found"
    end
  }

  register :load_repository_from_github, lambda { |repo|
    owner, repo_name = repo.full_name.split('/')
    github_repo = Github::Repository.find(owner: owner, repo: repo_name)
    if github_repo
      Right(repo: repo, github_repo: github_repo)
    else
      Left Error.new  :cannot_load,
                      "Repository #{repo_name} could not be loaded from Github"
    end
  }

  register :update_repository, lambda { |input|
    begin
      repo = input[:repo]
      github_repo = input[:github_repo]
      repo.update(
        github_id: github_repo.id, full_name: github_repo.full_name,
        is_private: github_repo.is_private, created_at: github_repo.created_at,
        pushed_at: github_repo.pushed_at, size: github_repo.size,
        stargazers_count: github_repo.stargazers_count,
        watchers_count: github_repo.watchers_count,
        forks_count: github_repo.forks_count,
        open_issues_count: github_repo.open_issues_count,
        language: github_repo.language,
        git_url: github_repo.git_url
      )
      Right(repo: repo, gh_repo: github_repo)
    rescue
      Left Error.new :cannot_load, 'Repository could not be updated'
    end
  }

  register :update_repo_stat, lambda { |input|
    begin
      repo = input[:repo]
      gh_repo = input[:gh_repo]
      update_stat_repo repo.stat, gh_repo.stats(stat_names: ['code_frequency','participation'])
      Right repo
    rescue
      Left Error.new :cannot_load, 'Repository stat could not be updated'
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

  register :link_repo_to_owner, lambda { |repo|
    begin
      owner, _ = repo.full_name.split('/')
      if(dev = Developer.find(username: owner))
        repo.udpate(developer_id: dev.id)
      end
      Right repo
    rescue
      Left Error.new :cannot_load, 'Repository could not be link to owner'
    end
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :check_if_repository_is_loaded
      step :load_repository_from_github
      step :update_repository
      step :update_repo_stat
      step :update_repo_code_quality
      step :link_repo_to_owner
    end.call(params)
  end

  def self.update_stat_repo(stat, new_stat)
    stat.update(
      code_frequency: new_stat[:code_frequency].to_s,
      participation: new_stat[:participation].to_s
    )
  end
end
