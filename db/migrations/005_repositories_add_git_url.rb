Sequel.migration do
  change do
    alter_table(:repositories) do
      add_column :git_url, String
    end
  end
end
