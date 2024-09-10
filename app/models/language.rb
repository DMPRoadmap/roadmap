# frozen_string_literal: true

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

# Object that represents a locale/language
class Language < ApplicationRecord
  # =============
  # = Constants =
  # =============

  ABBREVIATION_MAXIMUM_LENGTH = 5

  ABBREVIATION_FORMAT = /\A[a-z]{2}(-[A-Z]{2})?\Z/

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
                           uniqueness: { message: 'must be unique' },
                           length: { maximum: ABBREVIATION_MAXIMUM_LENGTH },
                           format: { with: ABBREVIATION_FORMAT }

  validates :default_language, inclusion: { in: BOOLEAN_VALUES }

  # =========================
  # = Custom Accessor Logic =
  # =========================

  # ensure abbreviation is downcase and conforms to I18n locales
  # TODO: evaluate the need for the LocaleService after move to Translation.io
  def abbreviation=(value)
    value = '' if value.nil?
    value = value.downcase
    if value.blank? || value =~ /\A[a-z]{2}\Z/i
      super
    else
      super(LocaleService.to_i18n(locale: value).to_s)
    end
  end

  # ==========
  # = Scopes =
  # ==========

  scope :sorted_by_abbreviation, -> { all.order(:abbreviation) }

  # Retrieves the id for a given abbreviation of a language
  scope :id_for, lambda { |abbreviation|
    where(abbreviation: abbreviation).pluck(:id).first
  }

  # ========================
  # = Public class methods =
  # ========================

  def self.many?
    Rails.cache.fetch([model_name, 'many?'], expires_in: 1.hour) { all.many? }
  end

  def self.default
    where(default_language: true).first
  end
end
