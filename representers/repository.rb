# frozen_string_literal: true
require_relative 'rubocop_score'
require_relative 'flog_score'

# Roar:Decorator for representing the developer
class RepositoryRepresenter < Roar::Decorator
  include Roar::JSON

  property :id
  property :github_id
  property :full_name
  property :is_private
  property :created_at
  property :pushed_at
  property :size
  property :stargazers_count
  property :watchers_count
  property :forks_count
  property :open_issues_count
  property :git_url
  property :flog_score, extend: FlogScoreRepresenter, class: FlogScore
  property :flay_score
  property :rubocop_score, extend: RubocopScoreRepresenter, class: RubocopScore
  property :language
end
