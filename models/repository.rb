# frozen_string_literal: true

# Represents a Repository's stored information
class Repository < Sequel::Model
  many_to_one :developer
  many_to_one :flogscore
  many_to_one :rubocopscore
end
