class Setting < ApplicationRecord
  self.table_name = 'projects_services'

  belongs_to :project
  belongs_to :service

  # delegate :name, to: :service, prefix: :service, allow_nil: true

  validates :project_id, uniqueness: { scope: [:service_id] }
  validates :project_id, presence: true
  validates :service_id, presence: true
  validate :json_value_format

  private

  def json_value_format
    begin
      hash = JSON.parse(value)
    rescue JSON::ParserError => e
      errors.add(:value, 'is not valid JSON')
      return
    end

    errors.add(:value, 'is empty') if hash.empty?
  end
end
