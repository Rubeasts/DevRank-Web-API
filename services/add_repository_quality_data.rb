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
      if repo.flogscore.nil?
        add_flogscore(repo, quality_data.get_flog_scores)
      else
        repo.flogscore.update quality_data.get_flog_scores
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

      if repo.rubocopscore.nil?
        add_rubocopscore(repo, quality_data.get_rubocop_errors)
      else
        repo.rubocopscore.update quality_data.get_rubocop_errors
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

  def self.add_flogscore(repo, flogscore)
    new_flogscore = Flogscore.create(
      total_score: flogscore[:total_score],
      max_score: flogscore[:max_score],
      average: flogscore[:average]
    )
    repo.flogscore = new_flogscore
    repo.flogscore.save
  end

  def self.add_rubocopscore(repo, rubocopscore)
    new_rubocopscore = Rubocopscore.create(
      offense_count: rubocopscore[:offense_count],
      target_file_count: rubocopscore[:target_file_count],
      inspected_file_count: rubocopscore[:inspected_file_count]
    )
    repo.rubocopscore = new_rubocopscore
    repo.rubocopscore.save
  end
end
