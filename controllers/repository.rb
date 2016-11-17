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
          {
            id: repo.id,
            github_id: repo.github_id,
            full_name: repo.full_name,
            is_private: repo.is_private,
            created_at: repo.created_at,
            pushed_at: repo.pushed_at,
            size: repo.size,
            stargazers_count: repo.stargazers_count,
            watchers_count: repo.watchers_count,
            forks_count: repo.forks_count,
            open_issues_count: repo.open_issues_count
          }.to_json
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