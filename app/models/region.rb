class Region < ActiveRecord::Base
  has_many :sub_regions, class_name: 'Region', foreign_key: 'super_region_id'
  
  belongs_to :super_region, class_name: 'Region'
  
  validates :name, presence: true, uniqueness: true
  validates :abbreviation, uniqueness: true, allow_nil: true
end