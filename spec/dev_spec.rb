# frozen_string_literal: true
require_relative 'spec_helper'

describe 'Dev Routes' do
  HAPPY_USERNAME = 'rjollet'.freeze
  SAD_USERNAME = '12547'.freeze

  before do
    VCR.insert_cassette DEV_CASSETTE, record: :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  describe 'Find developer by its github username' do
    it 'HAPPY: should find a developer given a correct username' do
      get "api/v0.1/dev/#{HAPPY_USERNAME}"

      last_response.status.must_equal 200
      last_response.content_type.must_equal 'application/json'
      dev_data = JSON.parse(last_response.body)
      dev_data['username'].must_equal HAPPY_USERNAME
    end

    it 'SAD: should report if a developer is not found' do
      get "api/v0.1/dev/#{SAD_USERNAME}"

      last_response.status.must_equal 404
      last_response.body.must_include SAD_USERNAME
    end
  end

  describe 'Get the list of repos of a developer' do
    it 'HAPPY should find repos of a developer' do
      get "api/v0.1/dev/#{HAPPY_USERNAME}/repos"

      last_response.status.must_equal 200
      last_response.content_type.must_equal 'application/json'
      repos_data = JSON.parse(last_response.body)
      repos_data['repos'].count.must_be :>=, 20
    end

    it 'SAD should report if the feed cannot be found' do
      get "api/v0.1/dev/#{SAD_USERNAME}/repos"

      last_response.status.must_equal 404
      last_response.body.must_include SAD_USERNAME
    end
  end
end
