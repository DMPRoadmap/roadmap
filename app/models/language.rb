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
  ##
  # Associations
  has_many :users
  has_many :orgs
  
  ##
  # Validations
  # Cannot do FastGettext translations here because we constantize LANGUAGES in initializers/constants.rb
  validates :abbreviation, presence: {message: "can't be blank"}, uniqueness: {message: "must be unique"}

  scope :sorted_by_abbreviation, -> { all.order(:abbreviation) }
  scope :default, -> { where(default_language: true).first }
  # Retrieves the id for a given abbreviation of a language
  scope :id_for, -> (abbreviation) { where(abbreviation: abbreviation).pluck(:id).first } 
end
