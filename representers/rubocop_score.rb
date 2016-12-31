# frozen_string_literal: true

# Roar:Decorator for representing the rubocop score
class RubocopScoreRepresenter < Roar::Decorator
  include Roar::JSON

  property :offense_count
  property :target_file_count
  property :inspected_file_count
end
