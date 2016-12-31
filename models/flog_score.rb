# frozen_string_literal: true

# Represents a Flog's stored information
class FlogScore < Sequel::Model
  one_to_one :repositories
end
