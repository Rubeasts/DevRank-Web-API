# frozen_string_literal: true

# Loads data from Facebook group to database
class LoadDeveloper
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :check_if_username, lambda { |input|
    puts input
    if input[:username]
      Right username: input[:username], channel_id: input[:channel_id]
    else
      Left Error.new  :bad_request,
                      "Should give a username"
    end
  }

  register :check_if_developer_is_loaded, lambda { |input|
    if (github_dev = Developer.find(username: input[:username]))
      Right Response.new(:loaded, DeveloperRepresenter.new(github_dev).to_json)
    else
      Concurrent::Promise.execute {
        LoadDeveloperFromGithub.call  username: input[:username],
                                      channel_id: input[:channel_id]
      }.then {
        DevRankAPI.publish  input[:channel_id],
                            "Complete"
      }
      Right Response.new(:loading, {channel_id: input[:channel_id]}.to_json)
    end
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :check_if_username
      step :check_if_developer_is_loaded
    end.call(params)
  end
end
