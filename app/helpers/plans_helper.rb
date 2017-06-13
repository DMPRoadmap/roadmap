module PlansHelper
  # Shows whether the user has default, template-default or custom settings
  # for the given plan.
  # --------------------------------------------------------
  def plan_settings_indicator(plan)
    plan_settings     = plan.super_settings(:export)
    template_settings = plan.template.try(:settings, :export)

    key = if plan_settings.try(:value?)
      plan_settings.formatting == template_settings.formatting ? "template_formatting" : "custom_formatting"
    elsif template_settings.try(:value?)
      "template_formatting"
    else
      "default_formatting"
    end

    content_tag(:small, t("helpers.settings.plans.#{key}"))
  end

  # display the role of the user for a given plan
  def display_role(role)
    if role.creator?
      access = _('Owner')
      
    else
      case role.access_level
        when 3
          access = _('Co-owner')
        when 2
          access = _('Editor')
        when 1
          access = _('Read only')
      end
    end
    return access
  end

  # display the visibility of the plan
  def display_visibility(val)
    case val
    when 'organisationally_visible'
      return _('My Inst.')
    when 'publicly_visible'
      return _('Public')
    else
      return _('Private')  # Both Test and Private
    end
  end

end
