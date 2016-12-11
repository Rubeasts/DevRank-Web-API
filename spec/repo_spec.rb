# frozen_string_literal: true
require_relative 'spec_helper'

describe 'Repository Routes' do
  before do
    VCR.insert_cassette REPO_CASSETTE, record: :new_episodes

    DB[:developers].delete
    DB[:repositories].delete
    LoadDeveloper.call(HAPPY_USERNAME)
  end

  after do
    VCR.eject_cassette
  end

  describe 'Get a repository of a developer' do
    it '(HAPPY) should find a repository from an owner and a repository name' do
      get "api/v0.1/dev/#{Repository.first.full_name}"
      last_response.status.must_equal 200
      last_response.content_type.must_equal 'application/json'
      repository = JSON.parse(last_response.body)
    end

    it '(SAD) should report error repositorie cannot be found' do
      get "api/v0.1/dev/#{SAD_USERNAME}/#{SAD_REPO}"

      last_response.status.must_equal 404
      last_response.body.must_include SAD_USERNAME
      last_response.body.must_include SAD_REPO
    end
  end
end
