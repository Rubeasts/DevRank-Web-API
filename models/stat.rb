# frozen_string_literal: true

# Represents a Rubocop's stored information
class Stat < Sequel::Model
  one_to_one :repositories
end
