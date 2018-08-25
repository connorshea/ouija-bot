Sequel.migration do
  up do
    add_column :settings, :archive, TrueClass, default: false
  end

  down do
    drop_column :settings, :archive
  end
end
