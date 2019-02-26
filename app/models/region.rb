# == Schema Information
#
# Table name: regions
#
#  id         :integer          not null, primary key
#  name       :string(30)       not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Region < ActiveRecord::Base

  has_many :org_regions

  has_many :orgs, through: :org_regions

  has_many :templates, through: :orgs

  has_many :guidances, through: :orgs

end
