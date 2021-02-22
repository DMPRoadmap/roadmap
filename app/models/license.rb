# frozen_string_literal: true

class License < ApplicationRecord

  # ================
  # = Associations =
  # ================

  has_many :research_outputs

  # ==========
  # = Scopes =
  # ==========

  scope :selectable, lambda {
    where(osi_approved: true, deprecated: false)
  }
end