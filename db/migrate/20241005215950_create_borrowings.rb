class CreateBorrowings < ActiveRecord::Migration[7.2]
  def change
    create_table :borrowings do |t|
      t.references :user,   null: false
      t.references :book,   null: false
      t.string     :state,  null: false
      t.datetime   :due_by, null: false

      t.timestamps
    end

    add_index :borrowings, [ :user_id, :book_id ], unique: true
  end
end
