# frozen_string_literal: true

# == Schema Information
#
# Table name: metadata_standards
#
#  id                  :bigint           not null, primary key
#  description         :text
#  locations           :json
#  related_entities    :json
#  title               :string
#  uri                 :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  rdamsc_id           :string
#
class MetadataStandard < ApplicationRecord

  # =============
  # = Constants =
  # =============

  # keep "=>" syntax as json_schemer requires string keys

  ######### Conclusion so far: overall type needs to be string instead of array on uat to pass Ruby validation
  ### Parse first (to string), and change overall type to string (but not converse the overall array to string)
  SCHEMA_RELATED_ENTITIES = {
    '$schema' => 'http://json-schema.org/draft-04/schema#',
    'type' => ['array','string'],
    'items' => {
      'type' => ['string','object'],
      'properties' => {
        'id' => { 'type' => 'string'},
        'role' => { 'type' => 'string'}
      }
    }
  }.freeze
  SCHEMA_LOCATIONS = {
    '$schema' => 'http://json-schema.org/draft-04/schema#',
    'type' => ['array','string'],
    'items' => {
      'type' => ['string','object'],
      'properties' => {
        'url' => { 'type' => 'string'},
        'type' => { 'type' => 'string'}
      }
    }
  }.freeze

  
  
  # SCHEMA_LOCATIONS = {
  #   '$schema' => 'http://json-schema.org/schema#',
  #   'type' => 'array',
  #   'items' => {
  #     'type' => 'object',
  #     'properties' => {
  #       'url' => { 'type' => ['object','array','string','null']},
  #       'type' => { 'type' => ['object','array','string','null'] }
  #     }
  #   }
  # }.freeze

  # ================
  # = Associations =
  # ================

  has_and_belongs_to_many :research_outputs

  # ==========
  # = Scopes =
  # ==========

  scope :search, lambda { |term|
    term = term.downcase
    where('LOWER(title) LIKE ?', "%#{term}%").or(where('LOWER(description) LIKE ?', "%#{term}%"))
  }

  # varchar(255) DEFAULT NULL
  validates :title,
            length: { maximum: 255 }

  # varchar(255) DEFAULT NULL
  validates :rdamsc_id,
            length: { maximum: 255 }

  # varchar(255) DEFAULT NULL
  validates :uri,
            length: { maximum: 255 }

  # json DEFAULT NULL
  validates :related_entities,
            json: {
              schema: SCHEMA_RELATED_ENTITIES,
              message: ->(errors) { errors }
            },
            allow_nil: true

  # json DEFAULT NULL
  validates :locations,
            json: {
              schema: SCHEMA_LOCATIONS,
              message: ->(errors) { errors }
            },
            allow_nil: true
end