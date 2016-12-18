# frozen_string_literal: true
source 'https://rubygems.org'
ruby '2.3.1'

gem 'econfig'
gem 'json'
gem 'puma'
gem 'rake'
gem 'sinatra'

gem 'getclonedata'
gem 'gitget'

gem 'sequel'

gem 'dry-container'
gem 'dry-monads'
gem 'dry-transaction'
gem 'concurrent-ruby'
gem 'multi_json'
gem 'roar'

group :development, :test do
  gem 'sqlite3'
end

group :development do
  gem 'rerun'

  gem 'flay'
  gem 'flog'
  gem 'rubocop'
end

group :test do
  gem 'minitest'
  gem 'minitest-rg'

  gem 'rack-test'

  gem 'vcr'
  gem 'webmock'
end

group :development, :production do
  gem 'hirb'
  gem 'tux'
end

group :production do
  gem 'pg'
end
