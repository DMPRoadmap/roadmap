# Used to link plans to guidance groups
# the links are created at plan creation stage
# and link to all  possible GGs
# then the selected field keeps track of which ones the user has turned on /off
#
class PlanGuidanceGroup < ActiveRecord::Base
  belongs_to :plan
  belongs_to :guidance_group

  attr_accessible :selected
end
