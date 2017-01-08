# frozen_string_literal: true

# Roar:Decorator for representing the stat
class StatRepresenter < Roar::Decorator
  include Roar::JSON

  property :code_frequency
  property :participation
end
