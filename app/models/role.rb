class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :plan
end
