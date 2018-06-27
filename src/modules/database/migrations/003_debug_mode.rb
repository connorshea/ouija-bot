Sequel.migration do
  up do
    add_column :settings, :debug_mode, TrueClass, default: false
  end

  down do
    drop_column :settings, :debug_mode
  end
end
