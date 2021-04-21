class ActionLog < ApplicationRecord
  enum status: { success: 'success', warning: 'warning', error: 'error' }
  enum action: { onboard: 'onboard', offboard: 'offboard', offboard_from_project: 'offboard_from_project' }
end
