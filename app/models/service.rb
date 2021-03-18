class Service < ApplicationRecord
  include Keyable

  has_many :settings
  has_many :projects, through: :settings

  validates :name, presence: true
end
