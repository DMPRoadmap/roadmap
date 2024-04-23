# frozen_string_literal: true

# == Schema Information
#
# Table name: repositories
#
#  id          :bigint(8)        not null, primary key
#  contact     :string
#  description :text             not null
#  homepage    :string
#  info        :json
#  name        :string           not null
#  uri         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_repositories_on_homepage  (homepage)
#  index_repositories_on_name      (name)
#  index_repositories_on_uri       (uri)
#
class Repository < ApplicationRecord
  # =============
  # = Constants =
  # =============

  # keep "=>" syntax as json_schemer requires string keys
  SCHEMA_INFO = {
    '$schema' => 'http://json-schema.org/draft-04/schema#',
    'type' => 'object',
    'properties' => {
      'types' => {
        'type' => 'array',
        'items' => {
          'type' => 'string'
        }
      },
      'keywords' => {
        'type' => 'array',
        'items' => {
          'type' => 'string'
        }
      },
      'subjects' => {
        'type' => 'array',
        'items' => {
          'type' => 'string'
        }
      },
      'access' => {
        'type' => 'string',
        'enum' => %w[open restricted closed]
      },
      'provider_types' => {
        'type' => 'array',
        'items' => {
          'type' => 'string'
        }
      },
      'upload_types' => {
        'type' => 'array',
        'items' => {
          'type' => 'object',
          'properties' => {
            'type' => { 'type' => 'string' },
            'restriction' => { 'type' => 'string' }
          },
          'required' => %w[type restriction]
        }
      },
      'policies' => {
        'type' => 'array',
        'items' => {
          'type' => 'object',
          'properties' => {
            'name' => { 'type' => 'string' },
            'url' => { 'type' => 'string' }
          },
          'required' => %w[name url]
        }
      },
      'pid_system' => {
        'type' => 'string'
      }
    }
  }.freeze

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

  # ===============
  # = Validations =
  # ===============

  # varchar(255) NOT NULL
  validates :name,
            presence: { message: PRESENCE_MESSAGE },
            length: { in: 0..255, allow_nil: false }

  # text NOT NULL
  validates :description,
            presence: { message: PRESENCE_MESSAGE }

  # varchar(255) NOT NULL
  validates :uri,
            presence: { message: PRESENCE_MESSAGE },
            length: { in: 0..255, allow_nil: false }

  # varchar(255) DEFAULT NULL
  validates :homepage,
            length: { maximum: 255 }

  # varchar(255) DEFAULT NULL
  validates :contact,
            length: { maximum: 255 }

  # json DEFAULT NULL
  validates :info,
            json: {
              schema: SCHEMA_INFO,
              message: ->(errors) { errors }
            },
            allow_nil: true
end
