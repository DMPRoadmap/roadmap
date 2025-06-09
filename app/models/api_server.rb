class ApiServer < ApplicationRecord
  validates :title, :description, presence: true
  has_many :templates
end
