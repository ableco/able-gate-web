class User < ApplicationRecord
  belongs_to :project, optional: true
  belongs_to :department, optional: true
  belongs_to :location, optional: true

  delegate :name, to: :department, prefix: :department, allow_nil: true
  delegate :name, to: :project, prefix: :project, allow_nil: true
  delegate :name, to: :location, prefix: :location, allow_nil: true

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :email, email: true
  validates :github, uniqueness: { case_sensitive: false, allow_nil: true }
  validates :project_id, presence: true

  def full_name = "#{first_name} #{last_name}"
end
