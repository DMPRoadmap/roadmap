class NewPlan < ActiveRecord::Base
  has_one :template
  has_many :roles
end
