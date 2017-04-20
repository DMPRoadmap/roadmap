class NewPlan < ActiveRecord::Base
  belongs_to :template
  has_many :roles
  has_many :users, through: :roles

  has_and_belongs_to_many :guidance_groups, join_table: "new_plans_guidance_groups"
end
