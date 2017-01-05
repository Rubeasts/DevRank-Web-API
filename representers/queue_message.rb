# frozen_string_literal: true

# Roar:Decorator for representing the rubocop score
class QueueMessageRepresenter < Roar::Decorator
  include Roar::JSON

  property :repo_id
  property :channel_id
end
