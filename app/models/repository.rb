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

  has_and_belongs_to_many :research_outputs

  # ==========
  # = Scopes =
  # ==========

  scope :by_type, lambda { |type|
    query_val = type.present? ? "%\"#{type}\"%" : "%"
    where("info->>'$.types' LIKE ?", query_val)
  }

  scope :by_subject, lambda { |subject|
    query_val = subject.present? ? "%\"#{subject}\"%" : "%"
    where("info->>'$.subjects' LIKE ?", query_val)
  }

  scope :search, lambda { |term|
    where("LOWER(name) LIKE ?", "%#{term}%")
      .or(where("info->>'$.keywords' LIKE ?", "%#{term}%"))
  }

  # A very specific keyword search (e.g. 'gene', 'DNA', etc.)
  scope :by_facet, lambda { |facet|
    where("info->>'$.keywords' LIKE ?", "%\"#{facet}\"%")
  }

end
