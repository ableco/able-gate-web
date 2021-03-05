class CreateServices < ActiveRecord::Migration[6.1]
  def change
    create_table :services do |t|
      t.string :name, null: false
      t.string :identifier, null: false

      t.timestamps
    end

    add_index :services, :identifier, unique: true
  end
end
