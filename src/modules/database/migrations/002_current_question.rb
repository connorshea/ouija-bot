Sequel.migration do
  up do
    add_column :settings, :current_question, String, default: ""
  end

  down do
    drop_column :settings, :currrent_question
  end
end
