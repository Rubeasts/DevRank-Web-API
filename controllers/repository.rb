# frozen_string_literal: true

# configure based on environment
class DevRankAPI < Sinatra::Base
  get "/#{API_VER}/repos/:owner/:repo/?" do
    result = LoadRepository.call(params)

    if result.success?
      content_type 'application/json'
      RepositoryRepresenter.new(result.value).to_json
    else
      ErrorRepresenter.new(result.value).to_status_response
    end
  end

  put "/#{API_VER}/repos/:owner/:repo/?" do
    result = UpdateRepository.call(params)

    if result.success?
      content_type 'application/json'
      status 204
      RepositoryRepresenter.new(result.value).to_json
    else
      ErrorRepresenter.new(result.value).to_status_response
    end
  end
end
