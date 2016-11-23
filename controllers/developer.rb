# frozen_string_literal: true

# configure based on environment
class DevRankAPI < Sinatra::Base
  get "/#{API_VER}/dev/:username/?" do
    result = LoadDeveloper.call(params[:username])

    if result.success?
      content_type 'application/json'
      DeveloperRepresenter.new(result.value).to_json
    else
      ErrorRepresenter.new(result.value).to_status_response
    end
  end

  put "/#{API_VER}/dev/:username/?" do
    result = UpdateDeveloper.call(params[:username])

    if result.success?
      content_type 'application/json'
      status 204
      DeveloperRepresenter.new(result.value).to_json
    else
      ErrorRepresenter.new(result.value).to_status_response
    end
  end
end
