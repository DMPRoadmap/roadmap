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
      return "<span title=\"#{ visibility_tooltip(val) }\">#{_('Institution: anyone at my institution can view')}</span>"
    when 'publicly_visible'
      return "<span title=\"#{ visibility_tooltip(val) }\">#{_('Public: anyone can view')}</span>"
    else
      return "<span title=\"#{ visibility_tooltip(val) }\">#{_('Private: restricted to me and people I invite')}</span>"  # Both Test and Private
    end
  end
  
  def visibility_tooltip(val)
    case val
    when 'organisationally_visible'
      return _('Institutional: anyone logged in from your institution can view, copy, or download the plan.')
    when 'publicly_visible'
      return _('Public: anyone can view, copy, or download the plan. It will appear on the Public DMPs page of this site.')
    else
      return _('Private: only owners, co-owners, and others with whom you shared your plan can directly view the plan. Administrators at your institution can view all plans for program development purposes. See the Terms of Use.')
    end
  end
end
