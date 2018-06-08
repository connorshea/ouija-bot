Sequel.migration do
  up do
    create_table(:settings) do
      primary_key :id
      TrueClass :enabled, default: true
      TrueClass :delete_all, default: false
      Bignum :guild_id, unique: true
    end
  end

  down do
    drop_table(:settings)
  end
end
