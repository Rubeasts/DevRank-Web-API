# frozen_string_literal: true
require_relative 'repository'

# Roar:Decorator for representing the developer
class DeveloperRepresenter < Roar::Decorator
  include Roar::JSON

  property :id
  property :github_id
  property :username
  property :avatar_url
  property :name
  property :location
  property :email
  property :followers
  property :following
  property :stars

  collection :repositories, extend: RepositoryRepresenter, class: Repository
end
