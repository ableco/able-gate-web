class User < ApplicationRecord
  belongs_to :project, optional: true
  belongs_to :department, optional: true
  belongs_to :location, optional: true

  delegate :name, to: :department, prefix: :department, allow_nil: true
  delegate :key, to: :department, prefix: :department, allow_nil: true
  delegate :name, to: :project, prefix: :project, allow_nil: true
  delegate :key, to: :project, prefix: :project, allow_nil: true
  delegate :name, to: :location, prefix: :location, allow_nil: true
  delegate :key, to: :location, prefix: :location, allow_nil: true

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :email, email: true
  validates :github, uniqueness: { case_sensitive: false, allow_nil: true }
  validates :project_id, presence: true, on: :create

  def full_name = "#{first_name} #{last_name}"

  def onboard!
    process_services_for(:onboard)
    update!(onboarded_at: Time.now)
  end

  def offboard!
    process_services_for(:offboard)
    update!(offboarded_at: Time.now)
  end

  def offboard_from_project!
    process_services_for(:offboard_from_project)
    update!(project_id: nil)
  end

  private

  def process_services_for(action_name)
    user = self
    common_settings = Setting.common.map { |setting| [setting.service_key, setting.json_value] }.to_h
    common_settings.default = {}

    user.project.settings.each do |setting|
      setting_plus_common = setting.json_value.merge(common_settings[setting.service_key])
      handler = Services[setting.service_key]

      unless handler.respond_to?(action_name)
        ActionLog.create!(user: user.email, project: setting.project_key, service: setting.service_key,
                          action: action_name, status: :warning, note: "#{action_name} method not defined for #{setting.service_key} handler")
        next
      end

      result = handler.send(action_name, member: user, configuration: setting_plus_common) || NULL_RESULT
      ActionLog.create!(user: user.email, project: setting.project_key, service: setting.service_key,
                        action: action_name, status: result.status, note: result.note)
    rescue StandardError => e
      ActionLog.create!(user: user.email, project: setting.project_key, service: setting.service_key,
                        action: action_name, status: :error, note: e.message)
    end
  end
end
