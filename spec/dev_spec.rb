# frozen_string_literal: true
require_relative 'spec_helper'

describe 'Dev Routes' do

  before do
    VCR.insert_cassette DEV_CASSETTE, record: :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  describe 'Find store developer by its github username' do
    before do
      DB[:developers].delete
      DB[:repositories].delete
      LoadDeveloper.call(HAPPY_USERNAME)
    end

    it 'HAPPY: should find a developer that has been loaded given it username' do
      get "api/v0.1/dev/#{HAPPY_USERNAME}"

      last_response.status.must_equal 200
      body = JSON.parse(last_response.body)
      body.must_include 'username'

      Developer.count.must_equal 1
      Repository.count.must_be :>=, 10
    end

    it 'SAD: should report if a developer is not found' do
      get "api/v0.1/dev/#{SAD_USERNAME}"

      last_response.status.must_equal 404
      last_response.body.must_include SAD_USERNAME
    end
  end

  describe 'Loading and saving a new developer by username' do
    before do
      DB[:developers].delete
      DB[:repositories].delete
    end

    it '(HAPPY) should load and save a new developers by its name' do
      get "api/v0.1/dev/#{HAPPY_USERNAME}"

      last_response.status.must_equal 200
      body = JSON.parse(last_response.body)
      body.must_include 'username'

      Developer.count.must_equal 1
      Repository.count.must_be :>=, 10
    end

    it '(BAD) should report error if given invalid name' do
      get "api/v0.1/dev/#{SAD_USERNAME}"

      last_response.status.must_equal 404
      last_response.body.must_include SAD_USERNAME
    end
  end

  describe 'Request to update a developer' do
    before do
      DB[:developers].delete
      DB[:repositories].delete
      LoadDeveloper.call(HAPPY_USERNAME)
    end

    it '(HAPPY) should successfully update valid developer' do
      original = Developer.first
      modified = Developer.first
      modified.github_id = nil
      modified.save
      put "api/v0.1/dev/#{HAPPY_USERNAME}"
      last_response.status.must_equal 204
      updated = Developer.first
      updated.github_id.must_equal(original.github_id)
      last_response.body == DeveloperRepresenter.new(original).to_json
    end

    it '(BAD) should report error if given invalid developer username' do
      put "api/v0.1/dev/#{SAD_USERNAME}"

      last_response.status.must_equal 404
      last_response.body.must_include SAD_USERNAME
    end
  end
end
