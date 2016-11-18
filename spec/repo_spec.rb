# frozen_string_literal: true
require_relative 'spec_helper'

describe 'Repository Routes' do
  before do
    VCR.insert_cassette REPO_CASSETTE, record: :new_episodes

    DB[:developers].delete
    DB[:repositories].delete
    post 'api/v0.1/dev',
         { name: HAPPY_USERNAME}.to_json,
         'CONTENT_TYPE' => 'application/json'
  end

  after do
    VCR.eject_cassette
  end

  describe 'Get all repositories of a developer' do
    it '(HAPPY) should find all repositories with valid group ID' do
      get "api/v0.1/dev/#{Developer.first.name}/repos"
      puts last_response
      last_response.status.must_equal 200
      last_response.content_type.must_equal 'application/json'
      repositories = JSON.parse(last_response.body)
      repositories['repositories'].count.must_be :>=, 5
    end

    it '(SAD) should report error repositories cannot be found' do
      get "api/v0.1/dev/#{SAD_USERNAME}/repos"

      last_response.status.must_equal 404
      last_response.body.must_include SAD_USERNAME
    end
  end
end
