# frozen_string_literal: true

# == Schema Information
#
# Table name: repositories
#
#  id          :bigint           not null, primary key
#  contact     :string
#  description :text             not null
#  info        :json
#  name        :string           not null
#  homepage    :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  uri         :string           not null
#
# Indexes
#
#  index_repositories_on_name     (name)
#  index_repositories_on_homepage (homepage)
#  index_repositories_on_uri      (uri)
#

class Repository < ApplicationRecord
  # ================
  # = Associations =
  # ================

  has_and_belongs_to_many :research_outputs

  # ==========
  # = Scopes =
  # ==========

  scope :by_type, lambda { |type|
    where(safe_json_where_clause(column: 'info', hash_key: 'types'), "%#{type}%")
  }

  scope :by_subject, lambda { |subject|
    where(safe_json_where_clause(column: 'info', hash_key: 'subjects'), "%#{subject}%")
  }

  scope :search, lambda { |term|
    term = term.downcase
    where('LOWER(name) LIKE ?', "%#{term}%")
      .or(where(safe_json_where_clause(column: 'info', hash_key: 'keywords'), "%#{term}%"))
      .or(where(safe_json_where_clause(column: 'info', hash_key: 'subjects'), "%#{term}%"))
  }

  # A very specific keyword search (e.g. 'gene', 'DNA', etc.)
  scope :by_facet, lambda { |facet|
    where(safe_json_where_clause(column: 'info', hash_key: 'keywords'), "%#{facet}%")
  }
end
