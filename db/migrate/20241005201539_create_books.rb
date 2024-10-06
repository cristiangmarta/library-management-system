class CreateBooks < ActiveRecord::Migration[7.2]
  def change
    create_table :books do |t|
      t.string  :title,        null: false
      t.string  :author,       null: false
      t.string  :genre,        null: false
      t.string  :isbn,         null: false
      t.integer :total_copies, null: false, default: 0

      t.timestamps
    end

    add_index :books, :isbn, unique: true
  end
end
