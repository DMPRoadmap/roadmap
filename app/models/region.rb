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

class Region < ActiveRecord::Base
  include ValidationMessages

  # ================
  # = Associations =
  # ================

  has_many :sub_regions, class_name: 'Region', foreign_key: 'super_region_id'

  belongs_to :super_region, class_name: 'Region'

  # ===============
  # = Validations =
  # ===============

  validates :name, presence: { message: PRESENCE_MESSAGE },
                   uniqueness: { message: UNIQUENESS_MESSAGE }

  validates :description, presence: true

  validates :abbreviation, presence: { message: PRESENCE_MESSAGE },
                           uniqueness: { message: UNIQUENESS_MESSAGE }

end
