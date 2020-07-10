# frozen_string_literal: true

# == Schema Information
#
# Table name: regions
#
#  id           :integer          not null, primary key
#  abbreviation :string
#  description  :string
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Region < ApplicationRecord

  # ================
  # = Associations =
  # ================

  has_many :sub_regions, class_name: "Region", foreign_key: "super_region_id"

  belongs_to :super_region, class_name: "Region", optional: true

  # ===============
  # = Validations =
  # ===============

  validates :name, presence: { message: PRESENCE_MESSAGE },
                   uniqueness: { message: UNIQUENESS_MESSAGE }

  validates :description, presence: true

  validates :abbreviation, presence: { message: PRESENCE_MESSAGE },
                           uniqueness: { message: UNIQUENESS_MESSAGE }

end
