# frozen_string_literal: true

# Roar:Decorator for representing the developer
class DeveloperRepresenter < Roar::Decorator
  include Roar::JSON

  property :id
  property :github_id
  property :username
end
