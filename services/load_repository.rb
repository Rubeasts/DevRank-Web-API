# frozen_string_literal: true
# Loads data from Facebook group to database
class LoadRepository
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :check_owner_repo_exist, lambda { |params|
    owner = params[:owner]
    repo = params[:repo]
    channel_id = params[:channel_id]

    if owner.nil? || repo.nil?
      Left Error.new  :bad_request,
                      'Bad Query, the request should be /repos/:owner/:repo'
    else
      Right(owner: owner, repo: repo, channel_id: channel_id)
    end
  }

  register :check_if_repository_is_loaded, lambda { |input|
    full_name = [input[:owner], input[:repo]].join('/')

    if (github_repo = Repository.find(full_name: full_name))
      Right github_repo
    else
      DevRankAPI.publish  input[:channel_id],
                          "Load #{input[:repo]} from Github"
      Concurrent::Promise.execute {
        LoadRepositoryFromGithub.call owner: input[:owner],
                                      repo: input[:repo],
                                      channel_id: input[:channel_id]
      }.then { |res|
        if res.success?
          DevRankAPI.publish  input[:channel_id],
                              "Completed #{input[:repo]}"
        else
          DevRankAPI.publish  input[:channel_id],
                              res.value.message
        end
      }
      Right Response.new(:loading, {channel_id: input[:channel_id]}.to_json)
    end
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :check_owner_repo_exist
      step :check_if_repository_is_loaded
    end.call(params)
  end
end
