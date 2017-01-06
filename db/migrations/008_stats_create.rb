Sequel.migration do
  up do
    create_table(:stats) do
      primary_key :id

      String :code_frequency, :text=>true
      String :participation, :text=>true
    end

    alter_table(:repositories) do
      add_foreign_key :stat_id, :stats
    end
  end

  down do
    alter_table(:repositories) do
      drop_foreign_key :stat_id
    end

    drop_table(:stats)
  end
end
