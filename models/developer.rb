# frozen_string_literal: true

# Represents a Developer's stored information
class Developer < Sequel::Model
  one_to_many :repositories
end
