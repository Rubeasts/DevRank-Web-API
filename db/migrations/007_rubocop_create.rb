Sequel.migration do
  up do
    create_table(:rubocopscores) do
      primary_key :id

      Fixnum :offense_count
      Fixnum :target_file_count
      Fixnum :inspected_file_count
    end

    alter_table(:repositories) do
      drop_column :rubocop_errors
      add_foreign_key :rubocopscore_id, :rubocopscores
    end
  end

  down do
    alter_table(:repositories) do
      drop_foreign_key :rubocopscore_id
      add_column :rubocop_errors, String
    end

    drop_table(:rubocopscores)
  end
end
