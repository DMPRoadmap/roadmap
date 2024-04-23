# frozen_string_literal: true

# == Schema Information
#
# Table name: static_page_contents
#
#  id             :integer          not null, primary key
#  content        :text
#  title          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  language_id    :integer          not null
#  static_page_id :integer          not null
#
# Indexes
#
#  index_static_page_contents_on_language_id     (language_id)
#  index_static_page_contents_on_static_page_id  (static_page_id)
#
# Foreign Keys
#
#  fk_rails_...  (language_id => languages.id)
#  fk_rails_...  (static_page_id => static_pages.id)
#

# StaticPageContent model, describe the content of a static page
class StaticPageContent < ApplicationRecord
  belongs_to :static_page, optional: true
  belongs_to :language

  validates :language, uniqueness: { scope: :static_page_id }
end
