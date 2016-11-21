# frozen_string_literal: true

# Input for SearchPostings
class UsernameRequestRepresenter < Roar::Decorator
  include Roar::JSON

  property :username
end
