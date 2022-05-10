# frozen_string_literal: true

# == Schema Information
#
# Table name: registry_values
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  description       :string
#  uri        :string
#  version    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  org_id :integer
#

# Object that represents a registry
class Registry < ApplicationRecord
  include ValidationMessages

  # ================
  # = Associations =
  # ================

  has_many :registry_values, dependent: :destroy

  belongs_to :org, optional: true

  # ===============
  # = Validations =
  # ===============

  validates :name, presence: { message: PRESENCE_MESSAGE }

  # ==========
  # = Scopes =
  # ==========

  scope :search, lambda { |term|
    search_pattern = "%#{term}%"
    where('lower(registries.name) LIKE lower(?) OR ' \
          'lower(registries.description) LIKE lower(?)',
          search_pattern, search_pattern)
  }
end
