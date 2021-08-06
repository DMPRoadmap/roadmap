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

  def self.make_query(field:, value:)
    mysql_db = ActiveRecord::Base.connection.adapter_name == "Mysql2"
    mysql_db ? %(info->>'$.types' LIKE  '%\"#{value}\"%') : %(info->>'#{field}' LIKE '%\"#{value}\"%')
  end

  # ================
  # = Associations =
  # ================

  has_and_belongs_to_many :research_outputs

  # ==========
  # = Scopes =
  # ==========

  scope :by_type, lambda { |type|
    where(make_query(field: 'types', value: type))
  }

  scope :by_subject, lambda { |subject|
    where(make_query(field: 'subjects', value: subject))
  }

  scope :search, lambda { |term|
    where("LOWER(name) LIKE ?", "%#{term}%")
      .or(where(make_query(field: 'keywords', value: term)))
  }

  # A very specific keyword search (e.g. 'gene', 'DNA', etc.)
  scope :by_facet, lambda { |facet|
    #where("info->>'$.keywords' LIKE ?", "%\"#{facet}\"%")
    where(make_query(field: 'subjects', value: facet))
  }

end
