# frozen_string_literal: true

# == Schema Information
#
# Table name: regions
#
#  id              :integer          not null, primary key
#  abbreviation    :string
#  description     :string
#  name            :string
#  super_region_id :integer
#

# Object that represents a regional area
class Region < ApplicationRecord
  # ================
  # = Associations =
  # ================

  has_many :sub_regions, class_name: 'Region', foreign_key: 'super_region_id'

  belongs_to :super_region, class_name: 'Region', optional: true

  # ===============
  # = Validations =
  # ===============

  validates :name, presence: { message: PRESENCE_MESSAGE },
                   uniqueness: { message: UNIQUENESS_MESSAGE,
                                 case_sensitive: false }

  validates :description, presence: true

  validates :abbreviation, presence: { message: PRESENCE_MESSAGE },
                           uniqueness: { message: UNIQUENESS_MESSAGE,
                                         case_sensitive: false }
end
