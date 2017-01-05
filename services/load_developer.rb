# frozen_string_literal: true

# Loads data from Facebook group to database
class LoadDeveloper
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :check_if_developer_is_loaded, lambda { |service_params|
    if (github_dev = Developer.find(username: service_params[:params]))
      Right github_dev
    else
      LoadDeveloperFromGithub.call service_params
    end
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :check_if_developer_is_loaded
    end.call(params)
  end
end
