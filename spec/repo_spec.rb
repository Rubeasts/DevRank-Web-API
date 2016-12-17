# frozen_string_literal: true
require_relative 'spec_helper'

describe 'Repository Routes' do
  before do
    VCR.insert_cassette REPO_CASSETTE, record: :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  describe 'Get a repository of a developer' do
    before do
      DB[:developers].delete
      DB[:repositories].delete
    end

    it '(HAPPY) should find a repo from an owner and a repo name' do
      LoadRepository.call(owner: HAPPY_USERNAME, repo: HAPPY_REPO)
      get "api/v0.1/repos/#{Repository.first.full_name}"
      last_response.status.must_equal 200
      last_response.content_type.must_equal 'application/json'
      last_response.body.must_equal(RepositoryRepresenter.new(Repository.first).to_json)
    end

    it '(HAPPY) should find a repo (not in db) from an owner and a repo name' do
      get "api/v0.1/repos/#{HAPPY_USERNAME}/#{HAPPY_REPO}"
      last_response.status.must_equal 200
      last_response.content_type.must_equal 'application/json'
      last_response.body.must_equal(RepositoryRepresenter.new(Repository.first).to_json)
    end

    it '(SAD) should report error repositorie cannot be found' do
      get "api/v0.1/repos/#{SAD_USERNAME}/#{SAD_REPO}"

      last_response.status.must_equal 404
      last_response.body.must_include SAD_USERNAME
      last_response.body.must_include SAD_REPO
    end
  end
end
