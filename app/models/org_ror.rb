# frozen_string_literal: true

# == Schema Information
#
# Table name: org_rors
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  org_id     :bigint(8)        not null
#  ror_id     :text             not null
#
# Indexes
#
#  index_org_rors_on_org_id  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#
class OrgRor < ApplicationRecord
  belongs_to :org

  
end
