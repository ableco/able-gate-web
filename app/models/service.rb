class Service < ApplicationRecord
  has_many :settings
  has_many :projects, through: :settings

  validates :name, presence: true
  validates :identifier, presence: true
end
