# frozen_string_literal: true

# configure based on environment
class DevRankAPI < Sinatra::Base
  get "/#{API_VER}/dev/:username/?" do
    developer_name = params[:username]
    begin
      dev = Developer.find(name: developer_name)

      content_type 'application/json'
      { id: dev.id, github_id: dev.github_id, name: dev.name }.to_json
    rescue
      halt 404, "Github Username: #{developer_name} not found"
    end
  end

  # Body args (JSON) e.g.: {"name": "githubusername"}
  post "/#{API_VER}/dev/?" do
    begin
      body_params = JSON.parse request.body.read
      developer_name = body_params['name']

      if Developer.find(name: developer_name)
        halt 422, "Developer (name: #{developer_name}) already exists"
      end

      github_dev = Github::Developer.find(username: developer_name)

      halt 404, "Developer (name: #{developer_name}) could not be found" unless github_dev
    rescue
      content_type 'text/plain'
      halt 404, "Developer (name: #{developer_name}) could not be found"
    end

    begin
      developer = Developer.create(
        github_id: github_dev.id,
        name: github_dev.name)

      github_dev.repos.each do |repo|
        Repository.create(
          developer_id: developer.id,
          github_id: repo.id,
          full_name: repo.full_name,
          is_private: repo.is_private,
          created_at: repo.created_at,
          pushed_at: repo.pushed_at,
          size: repo.size,
          stargazers_count: repo.stargazers_count,
          watchers_count: repo.watchers_count,
          forks_count: repo.forks_count,
          open_issues_count: repo.open_issues_count
        )
      end

      content_type 'application/json'
      status 202
      { id: developer.id, name: developer.name }.to_json
    rescue
      content_type 'text/plain'
      halt 500, "Cannot load developer (id: #{developer_name})"
    end
  end
end
