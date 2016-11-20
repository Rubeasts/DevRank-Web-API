# frozen_string_literal: true

# Loads data from Facebook group to database
class DisplayRepositories
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :validate_params, lambda { |params|
    begin
      developer_name = params['username']
      Right(developer_name)
    rescue
      Left(Error.new(:not_found, "Cannot find Username: #{developer_name} repos"))
    end
  }

  register :display_repositories, lambda { |developer_name|
    dev = Developer.find(name: developer_name)
    if dev
      Right(dev)
    else
      Left(Error.new(:not_found, "Cannot find Username: #{developer_name} repos"))
    end
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :validate_params
      step :display_repositories
    end.call(params)
  end
end
