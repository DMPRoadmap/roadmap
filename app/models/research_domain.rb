# frozen_string_literal: true

# == Schema Information
#
# Table name: research_domains
#
#  id         :bigint        not null, primary key
#  identifier :string        not null
#  label      :string        not null
#  created_at :datetime      not null
#  updated_at :datetime      not null
#  parent_id  :bigint
#
# Indexes
#
#  index_research_domains_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => research_domains.id)
#
class ResearchDomain < ApplicationRecord

  # ================
  # = Associations =
  # ================

  # Self join
  has_many :sub_fields, class_name: "ResearchDomain", foreign_key: "parent_id"
  belongs_to :parent, class_name: "ResearchDomain", optional: true

end
