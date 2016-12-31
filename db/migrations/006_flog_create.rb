Sequel.migration do
  up do
    alter_table(:repositories) do
      drop_column :flog_score
      add_foreign_key :flogscore_id, :flogscores
    end

    create_table(:flogscores) do
      primary_key :id

      Float :total_score
      Float :max_score
      Float :average
    end
  end

  down do
    alter_table(:repositories) do
      drop_foreign_key :flogscore_id
      add_column :flog_score, String
    end

    drop_table(:flogscores)
  end
end
