class CreateLocations < ActiveRecord::Migration[6.1]
  def change
    create_table :locations do |t|
      t.string :name, null: false
      t.string :identifier, null: false

      t.timestamps
    end
    add_index :locations, :identifier, unique: true
  end
end
