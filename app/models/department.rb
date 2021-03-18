class Department < ApplicationRecord
  include Keyable

  validates :name, presence: true
end
