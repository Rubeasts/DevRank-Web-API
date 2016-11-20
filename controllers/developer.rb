# frozen_string_literal: true

# configure based on environment
class DevRankAPI < Sinatra::Base
  get "/#{API_VER}/dev/:username/?" do
    result = FindDeveloper.call(params[:username])

    if result.success?
      content_type 'application/json'
      DeveloperRepresenter.new(result.value).to_json
    else
      ErrorRepresenter.new(result.value).to_status_response
    end
  end

  # Body args (JSON) e.g.: {"name": "githubusername"}
  post "/#{API_VER}/dev/?" do
    result = LoadDeveloperFromGithub.call(request.body.read)

    if result.success?
      content_type 'application/json'
      status 202
      DeveloperRepresenter.new(result.value).to_json
    else
      ErrorRepresenter.new(result.value).to_status_response
    end
  end
end
