# frozen_string_literal: true

# Input for SearchPostings
class NameRequestRepresenter < Roar::Decorator
  include Roar::JSON

  property :name
end
