# frozen_string_literal: true

# == Schema Information
#
# Table name: static_pages
#
#  id            :integer          not null, primary key
#  name          :string           not null
#  url           :string           not null
#  in_navigation :boolean          default("true")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# Static page class
class StaticPage < ApplicationRecord
  has_many :static_page_contents, dependent: :destroy
  accepts_nested_attributes_for :static_page_contents, allow_destroy: true

  alias contents static_page_contents

  validates :name, :url, presence: true, uniqueness: true

  # After initialization, also initialize Static Page Contents
  after_initialize if: :new_record? do
    (Language.all.to_a - contents.map(&:language)).each do |l|
      contents.new(language: l, content: '')
    end
  end

  scope :navigable, -> { StaticPage.where('in_navigation = ?', true) }

  # Get Static Page content for specified locale
  # @param locale requested locale for page content
  # @return [String] the localized Static Page Content
  def localized_content(locale)
    locale ||= Language.default.abbreviation
    p locale
    spc = contents.find_by(language: Language.find_by(abbreviation: locale))

    spc&.content
  end

  # Get Static Page title for specified locale
  # @param locale requested locale for page title
  # @return [String] the localized Static Page title
  def localized_name(locale)
    locale ||= Language.default.abbreviation
    if (spc = contents.find_by(language: Language.find_by(abbreviation: locale)))
      spc.title.empty? ? name : spc.title
    else
      name
    end
  end
end
