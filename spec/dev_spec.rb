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
      post 'api/v0.1/dev',
           { name: HAPPY_USERNAME }.to_json,
           'CONTENT_TYPE' => 'application/json'
    end

    it 'HAPPY: should find a developer given a correct username' do
      get "api/v0.1/dev/#{HAPPY_USERNAME}"

      last_response.status.must_equal 200
      last_response.content_type.must_equal 'application/json'
      dev_data = JSON.parse(last_response.body)
      dev_data['name'].must_equal HAPPY_USERNAME
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
      post 'api/v0.1/dev',
           {name:  HAPPY_USERNAME}.to_json,
           'CONTENT_TYPE' => 'application/json'

      last_response.status.must_equal 202
      body = JSON.parse(last_response.body)
      body.must_include 'name'

      Developer.count.must_equal 1
      Repository.count.must_be :>=, 10
    end

    it '(BAD) should report error if given invalid URL' do
      post 'api/v0.1/dev',
           { name: SAD_USERNAME }.to_json,
           'CONTENT_TYPE' => 'application/json'

      last_response.status.must_equal 404
      last_response.body.must_include SAD_USERNAME
    end

    it 'should report error if developer already exists' do
      2.times do
        post 'api/v0.1/dev',
             {name:  HAPPY_USERNAME}.to_json,
             'CONTENT_TYPE' => 'application/json'
      end

      last_response.status.must_equal 422
    end
  end
end
