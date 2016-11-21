# frozen_string_literal: true

# Loads data from Facebook group to database
class DisplayRepositories
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :validate_params, lambda { |params|
    begin
      dev_username = params['username']
      Right(dev_username)
    rescue
      Left(Error.new(:not_found, "Cannot find Username: #{dev_username} repos"))
    end
  }

  register :display_repositories, lambda { |dev_username|
    dev = Developer.find(username: dev_username)
    if dev
      Right(dev)
    else
      Left(Error.new(:not_found, "Cannot find Username: #{dev_username} repos"))
    end
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :validate_params
      step :display_repositories
    end.call(params)
  end
end
