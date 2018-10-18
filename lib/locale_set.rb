# frozen_string_literal: true

# A subclass of Set which holds locale values. Mediates between I18n and FastGettext which
# have different expectations of locale formats.
#
# Examples:
#
#   @locale_set = LocaleSet.new(["en_GB", "en", "fr", "de", :ch_TW])
#   @locale_set.for(:i18n) # => <LocaleSet: {'en-GB', 'en', 'fr', 'de', 'ch-TW'}>
#   @locale_set.for(:fast_gettext) # => <LocaleSet: {'en_GB', 'en', 'fr', 'de', 'ch_TW'}>
#
class LocaleSet < Set

  # The values from the Set in the desired format for the given localization framework
  #
  # framework - A symbol representing either :i18n or :fast_gettext (defaults: :i18n)
  #
  # Returns Array
  def for(framework)
    if framework.to_sym == :i18n
      self.class.new(map { |l| LocaleFormatter.new(l, format: :i18n).to_s })
    else
      self.class.new(map { |l| LocaleFormatter.new(l, format: :fast_gettext).to_s })
    end
  end

end
