# == Schema Information
#
# Table name: static_pages
#
#  id            :integer          not null, primary key
#  in_navigation :boolean          default(TRUE)
#  name          :string           not null
#  url           :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# Static page class
class StaticPage < ActiveRecord::Base
  has_many :static_page_contents, dependent: :destroy do
    # Create or update a content from a file
    # @param path path of the source file
    # @param language language for the content (default is default language)
    # @return [StaticPageContent] the created Static Page Content
    def from_file(path, language = Language.default)
      where(language: language)
        .first_or_create(language: language)
        .update(content: File.read(path))
    end
  end
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
  def localized_content(locale = Language.default.abbreviation)
    spc = contents.find_by(language: Language.find_by(abbreviation: locale))

    spc ? spc.content : nil
  end

  # Get Static Page title for specified locale
  # @param locale requested locale for page title
  # @return [String] the localized Static Page title
  def localized_name(locale = Language.default.abbreviation)
    if (spc = contents.find_by(language: Language.find_by(abbreviation: locale)))
      spc.title.empty? ? name : spc.title
    else
      name
    end
  end
end
