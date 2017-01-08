# frozen_string_literal: true

# configure based on environment
class DevRankAPI < Sinatra::Base
  get "/#{API_VER}/dev/:username/?" do
  	channel_id = (headers.to_s).hash
    puts "GET #{params[:username]}"
    result = LoadDeveloper.call(username: params[:username], channel_id: channel_id)
    if result.success?
      ResponseRepresenter.new(result.value).to_status_response
    else
      ErrorRepresenter.new(result.value).to_status_response
    end
  end

  put "/#{API_VER}/dev/:username/?" do
    result = UpdateDeveloper.call(params['username'])

    if result.success?
      content_type 'application/json'
      status 204
      DeveloperRepresenter.new(result.value).to_json
    else
      ErrorRepresenter.new(result.value).to_status_response
    end
  end
end
