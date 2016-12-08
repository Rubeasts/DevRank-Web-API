Sequel.migration do
  change do
  	alter_table(:repositories) do
  	  add_column :flog_score, String
  	  add_column :flay_score, String
      add_column :rubocop_errors, String
	end
  end
end
