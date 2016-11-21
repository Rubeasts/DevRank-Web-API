# frozen_string_literal: true
#require 'facegroup'
require 'dry-monads'

# Loads data from Facebook group to database
class FindDeveloper
  extend Dry::Monads::Either::Mixin

  def self.call(params)
    developer = Developer.find(username: params)
    if developer
      Right(developer)
    else
      Left(Error.new(:not_found, 'Developer not found'))
    end
  end
end
