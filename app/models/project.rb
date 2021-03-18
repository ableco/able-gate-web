class Project < ApplicationRecord
  include Keyable

  has_many :settings
  has_many :services, through: :settings

  validates :name, presence: true
end
