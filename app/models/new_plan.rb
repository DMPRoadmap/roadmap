class NewPlan < ActiveRecord::Base
  belongs_to :template
  has_many :roles
  has_many :users, through: :roles
end
