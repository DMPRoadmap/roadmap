# frozen_string_literal: true

# == Schema Information
#
# Table name: repositories
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  description  :text
#  url          :string
#  contact      :string
#  info         :json
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_repositories_on_name      (name)
#  index_repositories_on_url       (url)
#

class Repository < ApplicationRecord

  include Identifiable

  # serialize :info, JSON

  # ================
  # = Associations =
  # ================

  has_many :research_outputs

  # ==========
  # = Scopes =
  # ==========

  scope :search, lambda { |term|
    # The keyword search here is slightly different than the :by_facet scope.
    # It is more permissive, for example if the term is 'COVID' it will match the
    # 'COVID-19' keyword whereas the :by_facet scope is looking for an exact match
    where("LOWER(name) LIKE ?", "%#{term}%")
      .or(where("info->>'$.keywords' LIKE ?", "%#{term}%"))
  }

  scope :by_facet, lambda { |facet|
    where("info->>'$.keywords' LIKE ?", "%\"#{facet}\"%")
  }

end
