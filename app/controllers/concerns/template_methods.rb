module TemplateMethods

  private

  def template_type(template)
    template.customization_of.present? ? _("customisation") : _("template")
  end

end