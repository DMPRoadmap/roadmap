class Template < ActiveRecord::Base
  belongs_to :org
  has_many :new_phases
  has_many :new_plans
end
