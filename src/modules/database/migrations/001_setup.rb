Sequel.migration do
  up do
    create_table(:settings) do
      primary_key :id
      TrueClass :enabled, default: true
      Integer :guild_id, 
    end
  end

  down do
    drop_table(:settings)
  end
end
