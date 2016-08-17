class OrganisationType < ActiveRecord::Base
  attr_accessible :description, :name, :as => [:default, :admin]

  has_many :organisations

end
