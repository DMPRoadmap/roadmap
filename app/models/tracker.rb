class Tracker < ActiveRecord::Base
  belongs_to :org
  validates :code, format: { with: /\A\z|\AUA-[0-9]+-[0-9]+\z/,
    message: "wrong format" }
end
