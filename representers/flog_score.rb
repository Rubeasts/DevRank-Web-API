# frozen_string_literal: true

# Roar:Decorator for representing the rubocop score
class FlogScoreRepresenter < Roar::Decorator
  include Roar::JSON

  property :total_score
  property :max_score
  property :average
end
