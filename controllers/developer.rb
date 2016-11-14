# frozen_string_literal: true

# configure based on environment
class DevRankAPI < Sinatra::Base
  get "/#{API_VER}/dev/:username/?" do
    developer_id = params[:username]
    begin
      dev = Github::Developer.find(username: developer_id)

      content_type 'application/json'
      { userid: dev.id, username: dev.name }.to_json
    rescue
      halt 404, "Github Username: #{developer_id} not found"
    end
  end

  get "/#{API_VER}/dev/:username/repos/?" do
    developer_id = params[:username]
    begin
      dev = Github::Developer.find(username: developer_id)
      if !dev.nil?
        content_type 'application/json'
        { repos: dev.repos }.to_json
      else
        halt 404, "Cannot find Username: #{developer_id} repos"
      end
    rescue
      halt 404, "Cannot find Username: #{developer_id} repos"
    end
  end
end
