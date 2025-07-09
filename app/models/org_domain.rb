# frozen_string_literal: true

# == Schema Information
#
# Table name: org_domains
#
#  id         :bigint(8)        not null, primary key
#  domain     :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  org_id     :bigint(8)        not null
#
# Indexes
#
#  index_org_domains_on_org_id  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#
class OrgDomain < ApplicationRecord
  belongs_to :org
  
end
