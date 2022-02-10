# frozen_string_literal: true

module GlobalHelpers

  # overloading the method
  # came across a wierd issue where the function would refused to be called from
  # class functions of other classes... but it will work if this is a class function
  # easiest way to give this functionality is to overload the function
  # if you have a better solution, please impliment it as this is ugly
  def self.constant(str)
    I18n.t("magic_strings.#{str}", locale: I18n.default_locale)
  end

  private

  ##
  # Takes in a string which is meant to be constant, and looks it up in the default
  # (en_GB) locale.  This should ensure that the back-end remains constant and
  # consistantly called
  #
  # str - The String which will be looked up in the localisation
  #
  # Returns String
  def constant(str)
    I18n.t("magic_strings.#{str}", locale: I18n.default_locale)
  end

end
