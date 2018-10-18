module PlansHelper

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
      return "<span title=\"#{ visibility_tooltip(val) }\">#{_('Organisation')}</span>"
    when 'publicly_visible'
      return "<span title=\"#{ visibility_tooltip(val) }\">#{_('Public')}</span>"
    when 'privately_visible'
      return "<span title=\"#{ visibility_tooltip(val) }\">#{_('Private')}</span>"
    else
      return "<span>#{_('Private')}</span>" # Test Plans
    end
  end

  def visibility_tooltip(val)
    case val
    when 'organisationally_visible'
      return _('Organisation: anyone at my organisation can view.')
    when 'publicly_visible'
      return _('Public: anyone can view.')
    else
      return _('Private: restricted to me and people I invite.')
    end
  end

  def download_plan_page_title(plan, phase, hash)
    # If there is more than one phase show the plan title and phase title
    return hash[:phases].many? ? "#{plan.title} - #{phase[:title]}" : plan.title
  end

  def display_section?(customization, section, show_custom_sections)
    display = !customization
    display ||= customization && !section[:modifiable]
    display ||= customization && section[:modifiable] && show_custom_sections
    return display
  end
end
