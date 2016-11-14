require 'sequel'

Sequel.migration do
  change do
    create_table(:developers) do
      primary_key :id

      String :github_id
      String :name
    end
  end
end