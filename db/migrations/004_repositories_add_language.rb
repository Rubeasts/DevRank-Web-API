Sequel.migration do
  change do
    alter_table(:repositories) do
      add_column :language, String
    end
  end
end
