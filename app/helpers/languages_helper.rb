# frozen_string_literal: true

module LanguagesHelper

  def languages
    Rails.cache.fetch("languages", expires_in: 1.hour) { Language.sorted_by_abbreviation }
  end

end
