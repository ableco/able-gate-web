class AddOffboardFromProjectToActionLogAction < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      ALTER TABLE action_logs ALTER COLUMN action TYPE VARCHAR(255);
      DROP TYPE action_log_action;
      CREATE TYPE action_log_action AS ENUM ('onboard', 'offboard', 'offboard_from_project');
      ALTER TABLE action_logs ALTER COLUMN action TYPE action_log_action USING (action::action_log_action);
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE action_logs ALTER COLUMN action TYPE VARCHAR(255);
      DROP TYPE action_log_action;
      CREATE TYPE action_log_action AS ENUM ('onboard', 'offboard');
      ALTER TABLE action_logs ALTER COLUMN action TYPE action_log_action USING (action::action_log_action);
    SQL
  end
 end
