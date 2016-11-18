# frozen_string_literal: true

# configure based on environment
class DevRankAPI < Sinatra::Base
  get "/#{API_VER}/dev/:username/repos/?" do
    developer_name = params[:username]
    begin
      dev = Developer.find(name: developer_name)
      if !dev.nil?
        content_type 'application/json'
        repos = dev.repositories.map do |repo|
          RepositoryRepresenter.new(repo).to_json
        end
        { repositories: repos }.to_json
      else
        halt 404, "Cannot find Username: #{developer_name} repos"
      end
    rescue
      halt 404, "Cannot find Username: #{developer_name} repos"
    end
  end
end
