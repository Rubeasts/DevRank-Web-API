# frozen_string_literal: true
require_relative 'spec_helper'

describe 'API basics' do
  it 'should find configuration information' do
    app.config.GH_USERNAME.length.must_be :>, 0
    app.config.GH_TOKEN.length.must_be :>, 0
  end

  it 'should successfully find the root route' do
    get '/'
    last_response.body.must_include 'RankDev'
    last_response.status.must_equal 200
  end
end
