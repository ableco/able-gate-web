class CreateDepartments < ActiveRecord::Migration[6.1]
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.string :identifier, null: false

      t.timestamps
    end
    add_index :departments, :identifier, unique: true
  end
end
