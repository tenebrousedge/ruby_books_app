require 'sequel'
binding.pry
Sequel.migration do
  up do
    create_table(:books) do
      primary_key :id
      String :title, null: false
      String :author, null: false
      Time :created, null: false
      Time :modified
      index [:title, :author], unique: true
    end
  end

  down do
    drop_table(:books)
  end
end
