class NewPlan < ActiveRecord::Base
  has_one :template
  has_many :roles
  has_many :users, through: :roles
end
