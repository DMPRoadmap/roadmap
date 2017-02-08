=begin
class OrganisationType < ActiveRecord::Base
  ##
  # Attributes
  has_many :orgs

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :description, :organisations, :name, :as => [:default, :admin]

  ##
  # Validators
  validates :name, presence: true, uniqueness: true
end
=end