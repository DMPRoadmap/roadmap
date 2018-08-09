# == Schema Information
#
# Table name: languages
#
#  id               :integer          not null, primary key
#  abbreviation     :string
#  default_language :boolean
#  description      :string
#  name             :string
#

class Language < ActiveRecord::Base
  # frozen_string_literal: true

  include ValidationValues

  # =============
  # = Constants =
  # =============

  ABBREVIATION_MAXIMUM_LENGTH = 5

  ABBREVIATION_FORMAT = /\A[a-z]{2}(\_[A-Z]{2})?\Z/

  NAME_MAXIMUM_LENGTH = 20

  # ================
  # = Associations =
  # ================

  has_many :users

  has_many :orgs


  # ===============
  # = Validations =
  # ===============

  validates :name, presence: { message: "can't be blank" },
                   length: { maximum: NAME_MAXIMUM_LENGTH }

  validates :abbreviation, presence: { message: "can't be blank" },
                           uniqueness: { message: "must be unique" },
                           length: { maximum: ABBREVIATION_MAXIMUM_LENGTH },
                           format: { with: ABBREVIATION_FORMAT }

  validates :default_language, inclusion: { in: BOOLEAN_VALUES }

  # ==========
  # = Scopes =
  # ==========

  scope :sorted_by_abbreviation, -> { all.order(:abbreviation) }
  scope :default, -> { where(default_language: true).first }
  # Retrieves the id for a given abbreviation of a language
  scope :id_for, -> (abbreviation) {
    where(abbreviation: abbreviation).pluck(:id).first
  }
end
