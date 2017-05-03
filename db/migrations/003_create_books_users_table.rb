require 'sequel'

Sequel.migration do
  up do
    create_table(:books_users) do
      primary_key :id
      foreign_key :book_id, :books
      foreign_key :user_id, :users
      Time :checkout, null: false
      Time :due, null: false
      Time :returned
    end
  end

  down do
    drop_table(:books)
  end
end
