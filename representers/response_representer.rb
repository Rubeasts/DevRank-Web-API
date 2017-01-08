# frozen_string_literal: true
require 'json'

# Represents developer response to APP
class ResponseRepresenter < Roar::Decorator
  property :code
  property :data

  STATUS = {
    loaded: 200,
    loading: 202
  }.freeze

  def to_status_response
    [STATUS[@represented.code], {data: @represented.data}.to_json ]
  end
end
