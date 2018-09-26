# frozen_string_literal: true

# Takes a given locale string and formats it properly for the desired framework
#
# Examples:
#
#   @formatter = LocaleFormatter.new('en-GB').to_s # => 'en-GB'
#   @formatter = LocaleFormatter.new('en-GB', format: :fast_gettext).to_s # => 'en_GB'
#   @formatter = LocaleFormatter.new('en_GB', format: :i18n).to_s # => 'en-GB'
#
class LocaleFormatter

  # I18n formats use a hyphen to join the language and region
  I18N_JOIN = "-"

  # FastGettext formats use an underscore to join the language and region
  FAST_GETTEXT_JOIN = "_"

  # Regex to extract the components (language and region) from a locale String
  COMPONENT_FORMAT = /[a-z]{2}/i

  # The format to modify the String in
  #
  # Returns Symbol
  attr_reader :format

  # The formatted locale as a string
  #
  # Returns String
  attr_reader :string

  alias to_s string

  # Takes a given locale string and formats it properly for the desired framework
  #
  # string - A locale String (e.g. "en_GB", "en-GB", "en", :en)
  # format - A Symbol representing the desired translation framework (defaults: :i18n)
  #
  def initialize(string, format: :i18n)
    @format = format

    language, region = string.to_s.scan(COMPONENT_FORMAT)
    join_char = format.to_sym == :fast_gettext ? FAST_GETTEXT_JOIN : I18N_JOIN

    language.downcase! if language
    region.upcase!     if region

    if region.present?
      @string = "#{language}#{join_char}#{region}"
    else
      @string = language
    end
  end

end
