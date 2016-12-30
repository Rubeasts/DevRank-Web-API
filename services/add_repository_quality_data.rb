# frozen_string_literal: true

# Loads data from Facebook group to database
class UpdateRepositoryQualityData
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :parse_queue_message, lambda { |queue_message|
    begin
      message = QueueMessageRepresenter.new(
                  QueueMessage.new
                ).from_json(queue_message)
      Right message
    rescue
      Error.new :not_found, 'Cannot parse queue message'
    end
  }

  register :load_repository_quality_data, lambda { |message|
    repo = Repository.find(id: message[:repo_id])
    quality_data = GetCloneData::ClonedRepo.clone(git_url: repo.git_url)
    if quality_data.repo_path.nil?
      Left Error.new :not_found, 'Quality Data could not be found'
    else
      Right(repo: repo, quality_data: quality_data)
    end
  }

  register :save_flog_scores, lambda { |input|
    begin
      repo = input[:repo]
      quality_data = input[:quality_data]
      if repo.flog_score.nil?
        add_flog_score(repo, quality_data.get_flog_scores)
      else
        repo.flog_score.update quality_data.get_flog_scores
      end
      Right(repo: repo, quality_data: quality_data)
    rescue
      Left Error.new :cannot_load, 'Cannot save flog score'
    end
  }

  register :save_rubocop_scores, lambda { |input|
    begin
      repo = input[:repo]
      quality_data = input[:quality_data]

      if repo.rubocop_score_id.nil?
        add_rubocop_score(repo, quality_data.get_rubocop_errors)
      else
        repo.rubocop_score.update quality_data.get_rubocop_errors
      end

      Right(repo: repo, quality_data: quality_data)
    rescue
      Left Error.new :cannot_load, 'Cannot save rubocop score'
    end
  }

  register :save_repository_quality_data, lambda { |input|
    begin
      repo = input[:repo]
      quality_data = input[:quality_data]

      repo.flay_score = quality_data.get_flay_score
      repo.save
      quality_data.wipe

      Right repo
    rescue
      Left Error.new :cannot_load, 'Quality Data cannot be load'
    end
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :parse_queue_message
      step :load_repository_quality_data
      step :save_flog_scores
      step :save_rubocop_scores
      step :save_repository_quality_data
    end.call(params)
  end

  def self.add_flog_score(repo, flog_score)
    new_flog_score = FlogScore.create(
      total_score: flog_score[:total_score],
      max_score: flog_score[:max_score],
      average: flog_score[:average]
    )
    repo.flog_score = new_flog_score
    repo.flog_score.save
  end

  def self.add_rubocop_score(repo, rubocop_score)
    new_rubocop_score = RubocopScore.create(
      offense_count: rubocop_score[:offense_count],
      target_file_count: rubocop_score[:target_file_count],
      inspected_file_count: rubocop_score[:inspected_file_count]
    )
    repo.rubocop_score = new_rubocop_score
    repo.rubocop_score.save
  end
end
