# frozen_string_literal: true

# configure based on environment
class DevRankAPI < Sinatra::Base
  get "/#{API_VER}/dev/:username/repos/?" do
    results = DisplayRepositories.call(params)

    if results.success?
      content_type 'application/json'
      DeveloperRepositoriesRepresenter.new(results.value).to_json
    else
      ErrorRepresenter.new(results.value).to_status_response
    end
  end
end
