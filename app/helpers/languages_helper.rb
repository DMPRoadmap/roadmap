# frozen_string_literal: true

# Helper methods for Languages
module LanguagesHelper
  def languages
    Rails.cache.fetch('languages', expires_in: 1.hour) do
      # Only select languages that have a corresponding translation
      Language.sorted_by_abbreviation.select do |lang|
        File.exist?(
          Rails.root.join('config', 'locale', lang.abbreviation.gsub('-', '_'), 'client.po')
        )
      end
    end
  end
end
