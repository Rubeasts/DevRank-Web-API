# frozen_string_literal: true
require 'sequel'

Sequel.migration do
  change do
    create_table(:repositories) do
      primary_key :id
      foreign_key :developer_id

      String    :github_id
      String    :full_name
      TrueClass :is_private
      DateTime  :created_at
      DateTime  :pushed_at
      Fixnum    :size
      Fixnum    :stargazers_count
      Fixnum    :watchers_count
      Fixnum    :forks_count
      Fixnum    :open_issues_count
    end
  end
end
