class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :github
      t.boolean :admin, default: false
      t.integer :department_id
      t.integer :project_id
      t.integer :location_id

      t.timestamps
    end

    add_foreign_key :users, :projects
    add_foreign_key :users, :departments
    add_foreign_key :users, :locations

    add_index :users, :email, unique: true
    add_index :users, :github, unique: true
  end
end
