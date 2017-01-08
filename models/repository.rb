# frozen_string_literal: true

# Represents a Repository's stored information
class Repository < Sequel::Model
  many_to_one :developer
  many_to_one :flog_score
  many_to_one :rubocop_score
  many_to_one :stat
end
