# frozen_string_literal: true

# Represents a Rubocop's stored information
class Rubocopscore < Sequel::Model
  one_to_one :repositories
end
