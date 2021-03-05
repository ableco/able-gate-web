class CreateProjectsServices < ActiveRecord::Migration[6.1]
  def change
    create_table :projects_services do |t|
      t.integer :project_id
      t.integer :service_id
      t.jsonb :value, default: '{}'

      t.index %i[project_id service_id], unique: true

      t.timestamps
    end
  end
end
