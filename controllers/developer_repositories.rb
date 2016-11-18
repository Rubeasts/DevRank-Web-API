# frozen_string_literal: true
require_relative 'repository'
require 'multi_json'

# Represents overall group information for JSON API output
class DeveloperRepositoriesRepresenter < Roar::Decorator
  include Roar::JSON

  collection :repositories, extend: RepositoryRepresenter, class: Repository
end
