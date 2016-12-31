Sequel.migration do
  up do
    create_table(:rubocop_scores) do
      primary_key :id

      Fixnum :offense_count
      Fixnum :target_file_count
      Fixnum :inspected_file_count
    end

    alter_table(:repositories) do
      drop_column :rubocop_errors
      add_foreign_key :rubocop_score_id, :rubocop_scores
    end
  end

  down do
    alter_table(:repositories) do
      drop_foreign_key :rubocop_score_id
      add_column :rubocop_errors, String
    end

    drop_table(:rubocop_scores)
  end
end
