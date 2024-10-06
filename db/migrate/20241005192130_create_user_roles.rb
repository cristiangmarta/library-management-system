class CreateUserRoles < ActiveRecord::Migration[7.2]
  def change
    create_table :user_roles do |t|
      t.references :user,       index: false, foreign_key: true
      t.string     :role,       null: false
      t.datetime   :created_at, null: false
    end

    add_index :user_roles, :user_id
    add_index :user_roles, [ :user_id, :role ], unique: true
  end
end
