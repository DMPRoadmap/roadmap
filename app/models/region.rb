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
  has_many :sub_regions, class_name: 'Region', foreign_key: 'super_region_id'
  
  belongs_to :super_region, class_name: 'Region'
  
  validates :name, presence: {message: _("can't be blank")}, uniqueness: {message: _("must be unique")}
  validates :abbreviation, uniqueness: {message: _("must be unique")}, allow_nil: true
end
