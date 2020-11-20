# frozen_string_literal: true

class Tracker < ApplicationRecord

  belongs_to :org
  validates :code, format: { with: /\A\z|\AUA-[0-9]+-[0-9]+\z/,
                             message: "wrong format" }

end
