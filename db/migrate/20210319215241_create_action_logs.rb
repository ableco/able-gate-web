class CreateActionLogs < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE action_log_action AS ENUM ('onboard', 'offboard');
      CREATE TYPE action_log_status AS ENUM ('success', 'warning', 'error');
    SQL

    create_table :action_logs do |t|
      t.string :user
      t.string :project
      t.string :service
      t.text :note

      t.timestamps
    end

    add_column :action_logs, :action, :action_log_action
    add_column :action_logs, :status, :action_log_status
  end

  def down
    drop_table :action_logs
    execute <<-SQL
      DROP TYPE action_log_action;
      DROP TYPE action_log_status;
    SQL
  end
end
