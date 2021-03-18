class Location < ApplicationRecord
  include Keyable

  validates :name, presence: true
end
