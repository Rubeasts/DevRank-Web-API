# frozen_string_literal: true

# Roar:Decorator for representing the stat
class StatRepresenter < Roar::Decorator
  include Roar::JSON

  property :contributors
  property :commit_activity
  property :code_frequency
  property :participation
  property :punch_card
end
