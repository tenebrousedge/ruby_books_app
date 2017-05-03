Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      String :role, null: false
      String :username, null: false
      String :password, null: false
      Time :created, null: false
      Time :modified
      index [:username], unique: true
    end
  end

  down do
    drop_table(:users)
  end
end
