Sequel.migration do
  change do
    alter_table(:repositories) do
      drop_column :flog_score
      add_foreign_key :flog_score_id, :flog_scores
    end

    create_table(:flog_scores) do
      primary_key :id

      Float :total_score
      Float :max_score
      Float :average
    end
  end
end
