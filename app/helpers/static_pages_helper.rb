module StaticPagesHelper
  # Returns additionnal classes to make a Bootstrap tab active
  # Used to set active tab in Static Pages edition depending on the locale
  # @param locale locale abbreviation to check against
  # @param content add the 'in' class for tab content ? (optionnal)
  def active_tab?(locale, content = false)
    return "#{'in' if content} active" if locale == session[:locale]
    ''
  end
end