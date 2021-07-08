# frozen_string_literal: true

# == Schema Information
#
# Table name: metadata_standards
#
#  id                  :bigint(8)        not null, primary key
#  description         :text(65535)
#  locations           :json
#  related_entities    :json
#  title               :string(255)
#  uri                 :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  rdamsc_id           :string(255)
#
class MetadataStandard < ApplicationRecord

  # ================
  # = Associations =
  # ================

  has_and_belongs_to_many :research_outputs

  # ==========
  # = Scopes =
  # ==========

  scope :search, lambda { |term|
    where("LOWER(title) LIKE ?", "%#{term}%").or(where("LOWER(description) LIKE ?", "%#{term}%"))
  }

end
