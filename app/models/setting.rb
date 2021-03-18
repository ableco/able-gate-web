class Setting < ApplicationRecord
  self.table_name = 'projects_services'

  COMMON_SETTINGS_PROJECT_ID = -99_999

  belongs_to :project
  belongs_to :service

  delegate :key, to: :service, prefix: :service
  delegate :key, to: :project, prefix: :project

  validates :project_id, uniqueness: { scope: [:service_id] }
  validates :project_id, presence: true
  validates :service_id, presence: true
  validate :json_value

  scope :common, -> { where(project_id: COMMON_SETTINGS_PROJECT_ID) }

  def json_value
    hash = JSON.parse(value)
  rescue JSON::ParserError => e
    errors.add(:value, 'is not valid JSON')
    nil
  end
end
