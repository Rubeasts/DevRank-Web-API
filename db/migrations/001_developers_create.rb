require 'sequel'

Sequel.migration do
  change do
    create_table(:developers) do
      primary_key :id

      String :github_id
      String :username
      String :avatar_url
      String :name
      String :location
      String :email
    end
  end
end
