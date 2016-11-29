class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :new_plan
end
